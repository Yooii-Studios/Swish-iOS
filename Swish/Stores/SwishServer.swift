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
//    private let defaultParser = Parser<Result<AnyObject>>(parse: {
//        (result) -> Result<AnyObject> in return result })
    private static let host = "http://yooiia.iptime.org:3000"
    private static let baseClientUrl = host + "/clients"
    
    class func registerUser(callback: (me: Me) -> ()) {
        let params = [
            "uuid": UUIDHelper.uuid(),
            "gcm_id": "",
            "name": "iOS_dev",
            "about": "dev user on iOS"
        ]
        let parser = { (result: AnyObject) -> Me in
            let json = JSON(result)
            print(json)
            
            print("registered.")
            let id = json["user_id"].stringValue
            let token = json["token"].stringValue
            let me = Me.create(id, token: token, builder: { (me: Me) -> () in
                let userInfoJson = json["user_info"]
                me.name = userInfoJson["name"].stringValue
                me.about = userInfoJson["about"].stringValue
                me.profileUrl = userInfoJson["profile_image_url"].stringValue
                
                let levelInfoJson = json["current_level_info"]
                me.level = levelInfoJson["level"].intValue
                me.totalExpForNextLevel = levelInfoJson["total_exp_for_next"].intValue
                me.currentExp = levelInfoJson["current_exp"].intValue
            })
            return me
        }
        let httpRequest = HttpRequest<Me>(method: .POST, url: baseClientUrl, parameters: params, parser: parser, callback: callback)
        request(httpRequest)
    }
    
    class func updateUser(name: String? = nil, about: String? = nil, callback: (me: Me) -> ()) {
        let me = SwishDatabase.me()
        let url = "\(baseClientUrl)/\(me.id)/update_profile_info"
        
        var params = Dictionary<String, String>()
        params.updateValue("swish", forKey: "auth")
        if let name = name {
            params.updateValue(name, forKey: "name")
        }
        if let about = about {
            params.updateValue(about, forKey: "about")
        }
        
        let token = me.token
        let value = "Token token=\"\(token)\""
        let header = [ "Authorization": value ]
        
        Alamofire.request(.PUT, url, parameters: params, headers: header)
            .responseJSON { request, response, result in
                print("response: \(response)")
                if let result = result.value {
                    let json = JSON(result)
                    print(json)
                    callback(me: me)
                }
        }
    }
    
    class func getUser() {
        let url = "\(baseClientUrl)/6"
        
        var params = Dictionary<String, String>()
        params.updateValue("swish", forKey: "auth")
        
        let token = SwishDatabase.me().token
        let value = "Token token=\"\(token)\""
        let header = [ "Authorization": value ]
        
        Alamofire.request(.GET, url, parameters: params, headers: header)
            .responseJSON { request, response, result in
                print("response: \(response)")
                if let result = result.value {
                    let json = JSON(result)
                    print(json)
                }
        }
    }
    
    private class func request<T>(request: HttpRequest<T>) {
        Alamofire.request(request.method, request.url, parameters: request.parameters)
            .responseJSON { _, response, result in
                if let result = result.value {
                    request.callback(result: request.parser(result: result))
                }
        }
    }
}

final class HttpRequest<T> {
    typealias Parser = (result: AnyObject) -> T
    typealias Callback = (result: T) -> ()
    
    let method: Alamofire.Method
    let url: String
    let parameters: Dictionary<String, String>
    let parser: Parser
    let callback: Callback
    
    var useAuthHeader = true
    var timeout = 7
    
    init(method: Alamofire.Method, url: String,
        parameters: Dictionary<String, String> = Dictionary<String, String>(),
        parser: Parser, callback: Callback) {
            self.method = method
            self.url = url
            var tempParams = parameters
            tempParams.updateValue("swish", forKey: "auth")
            self.parameters = tempParams
            self.parser = parser
            self.callback = callback
    }
}
