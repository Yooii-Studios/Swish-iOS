//
//  SwishServer.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 15..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import Foundation
import Alamofire

typealias RawResult = Result<AnyObject>

final class SwishServer {
    static let defaultParser = { (result: JSON) -> JSON in return result }
    static let defaultCallback = { (result: JSON) -> () in }
    static let host = "http://yooiia.iptime.org:3000"
    
    class func request<T>(httpRequest: HttpRequest<T>) {
        var headers: [String: String]?
        if httpRequest.useAuthHeader {
            let me = SwishDatabase.me()
            let token = me.token
            let value = "Token token=\"\(token)\""
            headers = [ "Authorization": value ]
        }
        Alamofire.request(httpRequest.method,
            httpRequest.url,
            parameters: httpRequest.parameters,
            headers: headers)
            .responseJSON { _, response, result in
                if let statusCode = response?.statusCode {
                    if statusCode == 200 || statusCode == 201 {
                        httpRequest.onSuccess(result:
                            httpRequest.parser(result: JSON(result.value!)))
                    } else if statusCode >= 400 && statusCode <= 500 {
                        httpRequest.onFail(error:
                            SwishError(statusCode, json: JSON(result.value!)))
                    } else {
                        httpRequest.onFail(error:
                            SwishError.unknownError(statusCode))
                    }
                } else {
                    httpRequest.onFail(error: SwishError.unknownError())
                }
        }
        
    }
}


final class HttpRequest<T> {
    typealias Parser = (result: JSON) -> T
    typealias SuccessCallback = (result: T) -> ()
    typealias FailCallback = (error: SwishError) -> ()
    
    let method: Alamofire.Method
    let url: String
    let parameters: Dictionary<String, String>
    let parser: Parser
    let onSuccess: SuccessCallback
    let onFail: FailCallback
    
    var useAuthHeader = true
    var timeout = 7
    
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
}

final class SwishError: CustomStringConvertible {
    let statusCode: Int
    let code: Int
    let name: String
    let extras: String
    
    init(_ statusCode: Int, json: JSON) {
        self.statusCode = statusCode
        code = json["code"].intValue
        name = json["name"].stringValue
        extras = json["extra"].stringValue
    }
    
    private init(_ statusCode: Int) {
        self.statusCode = statusCode
        code = -1
        name = "UnknownError"
        extras = ""
    }
    
    var description: String {
        get {
            return "StatusCode: \(statusCode), Code: \(code), Name: \(name), extras: \(extras)"
        }
    }
    
    class func unknownError(statusCode: Int = -1) -> SwishError {
        return SwishError(statusCode)
    }
}
