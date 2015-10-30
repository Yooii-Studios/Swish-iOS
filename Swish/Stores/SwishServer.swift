//
//  SwishServer.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 15..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias DefaultSuccessCallback = (result: JSON) -> ()
typealias FailCallback = (error: SwishError) -> ()
typealias Param = Dictionary<String, String>
typealias Header = Dictionary<String, String>

private let invalidStatusCode = -1
private let invalidErrorCode = -1

final class SwishServer {
    static let defaultParser = { (result: JSON) -> JSON in return result }
    static let host = "http://yooiia.iptime.org:3000"
    private static let tagSeparator = "_"
    
    private var requests = Dictionary<String, HttpRequestProtocol>()
    
    // MARK: - Singleton
    
    private struct Instance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: SwishServer?
    }
    
    static var instance: SwishServer {
        get {
            dispatch_once(&Instance.dispatchToken) {
                Instance.instance = SwishServer()
            }
            return Instance.instance!
        }
    }
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Services
    
    class func requestWith<T>(httpRequest: HttpRequest<T>) {
        instance.requestWith(httpRequest)
    }
    
    func requestWith<T>(httpRequest: HttpRequest<T>) {
        let headers = SwishServer.createHeader(httpRequest)
        let alamofireManager = SwishServer.createManager(httpRequest)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
            let request = self.requestWith(httpRequest, alamofireManager: alamofireManager, headers: headers)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.addToRequests(httpRequest, alamofireManager: alamofireManager, request: request)
            }
        }
    }
    
    func requestWith<T>(httpRequest: HttpRequest<T>, alamofireManager: Manager, headers: Header?) -> Request {
        return alamofireManager.request(httpRequest.method,
            httpRequest.url,
            parameters: httpRequest.parameters,
            headers: headers)
            .responseJSON { response in
                self.handleResponse(httpRequest, response: response)
        }
    }
    
    func cancelWith(tag: String) {
        print("SwishServer.cancelWith for tag: \(tag)")
        requests[tag]?.cancel()
        if requests[tag] != nil {
            print("SwishServer.cancelWith for tag: \(tag) success")
        }
    }
    
    // MARK: - Helpers
    
    class func createTagWithPrefix(prefix: String, postfix: String? = nil) -> String {
        var tag = "\(prefix)"
        if let postfix = postfix {
            tag += "_\(postfix)"
        }
        return tag
    }
    
    private class func createHeader<T>(httpRequest: HttpRequest<T>) -> Header? {
        var headers: Header?
        if httpRequest.useAuthHeader {
            let me = SwishDatabase.me()
            let token = me.token
            let value = "Token token=\"\(token)\""
            headers = [ "Authorization": value ]
        }
        
        return headers
    }
    
    private class func createManager<T>(httpRequest: HttpRequest<T>) -> Alamofire.Manager {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = Double(httpRequest.timeout)
        configuration.timeoutIntervalForResource = Double(httpRequest.timeout)
        return Alamofire.Manager(configuration: configuration)
    }
    
    private func addToRequests<T>(httpRequest: HttpRequest<T>, alamofireManager: Manager, request: Request) {
        httpRequest.alamofireManager = alamofireManager
        httpRequest.request = request
        let tag = httpRequest.tag ?? "\(NSDate().timeIntervalSince1970)"
        httpRequest.tag = tag
        requests.updateValue(httpRequest, forKey: tag)
    }
    
    private func handleResponse<T>(httpRequest:HttpRequest<T>, response: Response<AnyObject, NSError>) {
        if let statusCode = response.response?.statusCode {
            if statusCode == 200 || statusCode == 201 {
                if response.result.isSuccess {
                    httpRequest.onSuccess(result:
                        httpRequest.parser(result: JSON(response.result.value!)))
                } else {
                    httpRequest.onFail(error: SwishError(statusCode, error: response.result.error!, urlRequest: response.request))
                }
            } else if statusCode >= 400 && statusCode <= 500 {
                let json = response.result.value != nil ? JSON(response.result.value!) : nil
                httpRequest.onFail(error: SwishError(statusCode, json: json, urlRequest: response.request))
            } else {
                httpRequest.onFail(error: SwishError.unknownError(statusCode, urlRequest: response.request))
            }
        } else {
            if let errorCode = response.result.error?.code where errorCode == NSURLErrorCancelled {
                // 요청이 취소된 경우는 따로 콜백을 부르지 않고 consume하도록 함
                print("User cancelled alamofire request: \(response.request)")
            } else {
                if let error = response.result.error {
                    httpRequest.onFail(error: SwishError(error: error, urlRequest: response.request))
                } else {
                    httpRequest.onFail(error: SwishError.unknownError(urlRequest: response.request))
                }
            }
        }
        requests.removeValueForKey(httpRequest.tag)
    }
}

protocol HttpRequestProtocol {
    func cancel()
}

final class HttpRequest<T>: HttpRequestProtocol {
    typealias Parser = (result: JSON) -> T
    typealias SuccessCallback = (result: T) -> ()
    typealias FailCallback = (error: SwishError) -> ()
    
    let method: Alamofire.Method
    let url: String
    let parameters: Dictionary<String, String>
    let parser: Parser
    let onSuccess: SuccessCallback
    let onFail: FailCallback
    
    var tag: String!
    var useAuthHeader = true
    // TODO: 안드로이드와 같이 7초의 timeout이 bad network에서 timeout에 자주 걸려 임의로 2배로 설정함
    // 테스트를 통해 조절 필요(Retry policy등)
    var timeout:NSTimeInterval = 14
    
    private var alamofireManager: Alamofire.Manager?
    private var request: Request?
    
    init(method: Alamofire.Method, url: String,
        parameters: Dictionary<String, String> = Dictionary<String, String>(),
        parser: Parser, onSuccess: SuccessCallback, onFail: FailCallback) {
            self.method = method
            self.url = url
            var tempParams = parameters
            tempParams.updateValue("swish", forKey: "auth")
            self.parameters = tempParams
            self.parser = parser
            self.onSuccess = onSuccess
            self.onFail = onFail
    }
    
    func cancel() {
        request?.cancel()
    }
}

final class SwishError: CustomStringConvertible {
    
    let statusCode: Int
    let code: Int?
    let name: String?
    let extras: String?
    let urlRequest: NSURLRequest?
    
    init(_ statusCode: Int, error: NSError, urlRequest: NSURLRequest? = nil) {
        self.statusCode = statusCode
        code = invalidErrorCode
        name = "UnknownError"
        extras = String(error)
        self.urlRequest = urlRequest
    }
    
    init(_ statusCode: Int, json: JSON?, urlRequest: NSURLRequest? = nil) {
        self.statusCode = statusCode
        code = json?["code"].intValue
        name = json?["name"].stringValue
        extras = json?["extra"].stringValue
        self.urlRequest = urlRequest
    }
    
    convenience init(error: NSError, urlRequest: NSURLRequest? = nil) {
        self.init(invalidStatusCode, error: error, urlRequest: urlRequest)
    }
    
    private init(_ statusCode: Int, urlRequest: NSURLRequest? = nil) {
        self.statusCode = statusCode
        code = invalidErrorCode
        name = "UnknownError"
        extras = ""
        self.urlRequest = urlRequest
    }
    
    var description: String {
        get {
            return "StatusCode: \(statusCode), Code: \(code), Name: \(name), extras: \(extras),"
                + " urlRequest: \(urlRequest)"
        }
    }
    
    class func unknownError(statusCode: Int = invalidStatusCode, urlRequest: NSURLRequest? = nil) -> SwishError {
        return SwishError(statusCode, urlRequest: urlRequest)
    }
}
