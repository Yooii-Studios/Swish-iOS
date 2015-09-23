//
//  UserServer.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 17..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import Foundation
import UIKit

final class UserServer {
    private static let baseClientUrl = SwishServer.host + "/clients"
    
    class func registerMe(onSuccess: (me: Me) -> (), onFail: FailCallback) {
        let params = registerMeParams()
        let parser = { (resultJson: JSON) -> Me in return meFrom(resultJson) }
        let httpRequest = HttpRequest<Me>(method: .POST, url: baseClientUrl, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
        httpRequest.useAuthHeader = false
        
        SwishServer.requestWith(httpRequest)
    }
    
    class func updateMe(name: String? = nil, about: String? = nil,
        onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
            let url = "\(baseClientUrl)/\(SwishDatabase.me().id)/update_profile_info"
            let params = updateMeParamsWith(name, about: about)
            
            let httpRequest = HttpRequest<JSON>(method: .PUT, url: url, parameters: params, parser: SwishServer.defaultParser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func updateMyProfileImage(image: UIImage,
        onSuccess: (profileImageUrl: String) -> (), onFail: FailCallback) {
            let url = "\(baseClientUrl)/\(SwishDatabase.me().id)/update_profile_image"
            let params = updateMyProfileImageParamsWith(image)
            let parser = { (result: JSON) -> String in
                return myProfileImageUrlFrom(result)
            }
            
            let httpRequest = HttpRequest<String>(method: .PUT, url: url, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func opponentUserWith(userId: String, onSuccess: (opponentUser: OpponentUser) -> (), onFail: FailCallback) {
        let url = "\(baseClientUrl)/\(userId)"
        
        let parser = { (resultJson: JSON) -> OpponentUser in
            return opponentUserFrom(resultJson, userId: userId)
        }
        
        let httpRequest = HttpRequest<OpponentUser>(
            method: .GET, url: url, parser: parser, onSuccess: onSuccess, onFail: onFail)
        
        SwishServer.requestWith(httpRequest)
    }
    
    class func activityRecordWith(id: String, onSuccess: (record: UserActivityRecord) -> (),
        onFail: FailCallback) {
            let url = "\(baseClientUrl)/\(id)/get_activity_record"
            
            let parser = { (resultJson: JSON) -> UserActivityRecord in
                let userInfoJson = resultJson["user_info"]
                return userActivityRecordFrom(userInfoJson)
            }
            
            let httpRequest = HttpRequest<UserActivityRecord>(
                method: .GET, url: url, parser: parser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    // MARK: - Params
    private class func registerMeParams() -> Param {
        return [
            "uuid": UUIDHelper.uuid(),
            "gcm_id": "",
            "name": "iOS_dev",
            "about": "dev user on iOS"
        ]
    }
    
    private class func updateMeParamsWith(name: String? = nil, about: String? = nil) -> Param {
        var params = Param()
        if let name = name {
            params.updateValue(name, forKey: "name")
        }
        if let about = about {
            params.updateValue(about, forKey: "about")
        }
        
        return params
    }
    
    private class func updateMyProfileImageParamsWith(image: UIImage) -> Param {
        let encoded = UIImagePNGRepresentation(image)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return [
            "image_resource": encoded!
        ]
    }
    
    // MARK: - Parsers
    private class func meFrom(resultJson: JSON) -> Me {
        let id = resultJson["user_id"].stringValue
        let token = resultJson["token"].stringValue
        return Me.create(id, token: token, builder: { (me: Me) -> () in
            let userInfoJson = resultJson["user_info"]
            me.name = userInfoJson["name"].stringValue
            me.about = userInfoJson["about"].stringValue
            me.profileUrl = userInfoJson["profile_image_url"].stringValue
            
            let levelInfoJson = resultJson["current_level_info"]
            me.level = levelInfoJson["level"].intValue
            me.totalExpForNextLevel = levelInfoJson["total_exp_for_next"].intValue
            me.currentExp = levelInfoJson["current_exp"].intValue
        })
    }
    
    private class func myProfileImageUrlFrom(resultJson: JSON) -> String {
        return resultJson["profile_image_url"].stringValue
    }
    
    private class func opponentUserFrom(resultJson: JSON, userId: String) -> OpponentUser {
        let opponentUser = OpponentUser.create(userId, builder: { (opponentUser: OpponentUser) -> () in
            let userInfoJson = resultJson["user_info"]
            
            opponentUser.name = userInfoJson["name"].stringValue
            opponentUser.about = userInfoJson["about"].stringValue
            opponentUser.profileUrl = userInfoJson["profile_image_url"].stringValue
            opponentUser.level = userInfoJson["level"].intValue
            opponentUser.userActivityRecord = userActivityRecordFrom(userInfoJson)
            opponentUser.recentlySentPhotoUrls.appendContentsOf(photoMetadataListFrom(userInfoJson))
        })
        return opponentUser
    }
    
    private class func userActivityRecordFrom(userInfoJson: JSON) -> UserActivityRecord {
        let activityRecordJson = userInfoJson["activity_record"]
        return UserActivityRecord(
            sentPhotoCount: activityRecordJson["upload_photo_count"].intValue,
            likedPhotoCount: activityRecordJson["like_get_count"].intValue,
            dislikedPhotoCount: activityRecordJson["dislike_get_count"].intValue)
    }
    
    private class func photoMetadataListFrom(userInfoJson: JSON) -> Array<PhotoMetadata> {
        let photoMetadataListJson = userInfoJson["recently_send_photo_urls"].arrayValue
        var photoMetadataList = Array<PhotoMetadata>()
        for photoMetadataJson in photoMetadataListJson {
            let url = photoMetadataJson["send_photo_url"].stringValue
            photoMetadataList.append(PhotoMetadata(url: url))
        }
        return photoMetadataList
    }
}
