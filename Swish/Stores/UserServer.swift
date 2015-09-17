//
//  UserServer.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 17..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import Foundation

final class UserServer {
    typealias FailCallback = (error: SwishError) -> ()
    
    private static let baseClientUrl = SwishServer.host + "/clients"
    
    class func registerUser(onSuccess: (me: Me) -> (), onFail: FailCallback) {
        let params = [
            "uuid": UUIDHelper.uuid(),
            "gcm_id": "",
            "name": "iOS_dev",
            "about": "dev user on iOS"
        ]
        let parser = { (resultJson: JSON) -> Me in
            print(resultJson)
            
            print("registered.")
            let id = resultJson["user_id"].stringValue
            let token = resultJson["token"].stringValue
            let me = Me.create(id, token: token, builder: { (me: Me) -> () in
                let userInfoJson = resultJson["user_info"]
                me.name = userInfoJson["name"].stringValue
                me.about = userInfoJson["about"].stringValue
                me.profileUrl = userInfoJson["profile_image_url"].stringValue
                
                let levelInfoJson = resultJson["current_level_info"]
                me.level = levelInfoJson["level"].intValue
                me.totalExpForNextLevel = levelInfoJson["total_exp_for_next"].intValue
                me.currentExp = levelInfoJson["current_exp"].intValue
            })
            return me
        }
        let httpRequest = HttpRequest<Me>(method: .POST, url: baseClientUrl, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
        httpRequest.useAuthHeader = false
        SwishServer.request(httpRequest)
    }
    
    class func updateUser(name: String? = nil, about: String? = nil, onFail: FailCallback) {
        let me = SwishDatabase.me()
        let url = "\(baseClientUrl)/\(me.id)/update_profile_info"
        
        var params = Dictionary<String, String>()
        if let name = name {
            params.updateValue(name, forKey: "name")
        }
        if let about = about {
            params.updateValue(about, forKey: "about")
        }
        
        let httpRequest = HttpRequest<JSON>(method: .PUT, url: url, parameters: params, parser: SwishServer.defaultParser, onSuccess: SwishServer.defaultCallback, onFail: onFail)
        
        SwishServer.request(httpRequest)
    }
    
//    class func getUser(callback: (opponentUser: OpponentUser) -> ()) {
//        let url = "\(baseClientUrl)/6"
//        
//        var params = Dictionary<String, String>()
//        params.updateValue("swish", forKey: "auth")
//        
//        let token = SwishDatabase.me().token
//        let value = "Token token=\"\(token)\""
//        let header = [ "Authorization": value ]
//        
//        let parser = { (resultJson: JSON) -> OpponentUser in
//            OpponentUser.create(id: ID)
//            return nil
//        }
//        
//        let httpRequest = HttpRequest<OpponentUser>(
//            method: .GET, url: url, parameters: params, parser: parser, callback: callback)
//        
//        SwishServer.request(httpRequest)
////        Alamofire.request(.GET, url, parameters: params, headers: header)
////            .responseJSON { request, response, result in
////                print("response: \(response)")
////                if let result = result.value {
////                    let json = JSON(result)
////                    print(json)
////                }
////        }
//    }
}
