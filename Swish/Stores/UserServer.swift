//
//  UserServer.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 17..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift

final class UserServer {
    
    private static let BaseClientUrl = SwishServer.Host + "/clients"
    
    class func registerMe(name: String? = nil, about: String? = nil,
        image: UIImage? = nil, onSuccess: (me: Me) -> (), onFail: FailCallback) {
            let params = registerMeParamsWith(name, about: about, image: image)
            let parser = { (resultJson: JSON) -> Me in return meFrom(resultJson) }
            let httpRequest = HttpRequest<Me>(method: .POST, url: BaseClientUrl, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.useAuthHeader = false
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func updateMe(id: User.ID, name: String? = nil, about: String? = nil,
        onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
            let url = "\(BaseClientUrl)/\(id)/update_profile_info"
            let params = updateMeParamsWith(name, about: about)
            
            let httpRequest = HttpRequest<JSON>(method: .PUT, url: url, parameters: params, parser: SwishServer.DefaultParser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func updateMyDeviceToken(id: User.ID, deviceToken: String,
        onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
            let url = "\(BaseClientUrl)/\(id)"
            let params = updateMyDeviceTokenParamsWith(deviceToken)
            
            let httpRequest = HttpRequest<JSON>(method: .PATCH, url: url, parameters: params,
                parser: SwishServer.DefaultParser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func updateMyProfileImage(id: User.ID, image: UIImage,
        onSuccess: (profileImageUrl: String) -> (), onFail: FailCallback) {
            let url = "\(BaseClientUrl)/\(id)/update_profile_image"
            let params = updateMyProfileImageParamsWith(image)
            let parser = { (result: JSON) -> String in
                return myProfileImageUrlFrom(result)
            }
            
            if let params = params {
                let httpRequest = HttpRequest<String>(method: .PUT, url: url, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
                
                SwishServer.requestWith(httpRequest)
            } else {
                onFail(error: SwishError.unknownError())
            }
    }
    
    class func otherUserWith(userId: User.ID, onSuccess: (otherUser: OtherUser) -> (), onFail: FailCallback) {
        let url = "\(BaseClientUrl)/\(userId)"
        
        let parser = { (resultJson: JSON) -> OtherUser in
            return otherUserFrom(resultJson, userId: userId)
        }
        
        let httpRequest = HttpRequest<OtherUser>(
            method: .GET, url: url, parser: parser, onSuccess: onSuccess, onFail: onFail)
        
        SwishServer.requestWith(httpRequest)
    }
    
    class func activityRecordWith(id: User.ID, onSuccess: (record: UserActivityRecord) -> (),
        onFail: FailCallback) {
            let url = "\(BaseClientUrl)/\(id)/get_activity_record"
            
            let parser = { (resultJson: JSON) -> UserActivityRecord in
                let userInfoJson = resultJson["user_info"]
                return userActivityRecordFrom(userInfoJson)
            }
            
            let httpRequest = HttpRequest<UserActivityRecord>(
                method: .GET, url: url, parser: parser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    // MARK: - Params
    
    private class func registerMeParamsWith(name: String? = nil, about: String? = nil,
        image: UIImage? = nil) -> Param {
        var params = Param()
        params.updateValue(UUIDHelper.uuid(), forKey: "uuid")
        // TODO: APNS 토큰 적용
        params.updateValue("", forKey: "gcm_id")
        // 1 = iOS
        params.updateValue("1", forKey: "client_type")
        if let name = name {
            params.updateValue(name, forKey: "name")
        }
        if let about = about {
            params.updateValue(about, forKey: "about")
        }
        if let image = image {
            if let encodedImage = image.base64EncodedString {
                params.updateValue(encodedImage, forKey: "image_resource")
            }
        }
        
        return params
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
    
    private class func updateMyDeviceTokenParamsWith(deviceToken: String) -> Param {
        var params = Param()
        params.updateValue(deviceToken, forKey: "gcm_registeration_id")

        return params
    }
    
    private class func updateMyProfileImageParamsWith(image: UIImage) -> Param? {
        let encoded = image.base64EncodedString
        return encoded != nil ? [ "image_resource": encoded! ] : nil
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
    
    private class func otherUserFrom(resultJson: JSON, userId: String) -> OtherUser {
        let otherUser = OtherUser.create(userId) {
            let userInfoJson = resultJson["user_info"]
            
            $0.name = userInfoJson["name"].stringValue
            $0.about = userInfoJson["about"].stringValue
            $0.profileUrl = userInfoJson["profile_image_url"].stringValue
            $0.level = userInfoJson["level"].intValue
            $0.userActivityRecord = userActivityRecordFrom(userInfoJson)
            $0.recentlySentPhotoUrls = List<PhotoMetadata>(initialArray: photoMetadataListFrom(userInfoJson))
        }
        return otherUser
    }
    
    private class func userActivityRecordFrom(userInfoJson: JSON) -> UserActivityRecord {
        let activityRecordJson = userInfoJson["activity_record"]
        return UserActivityRecord(
            sentPhotoCount: activityRecordJson["upload_photo_count"].intValue,
            likedPhotoCount: activityRecordJson["like_get_count"].intValue,
            dislikedPhotoCount: activityRecordJson["dislike_get_count"].intValue)
    }
    
    private class func photoMetadataListFrom(userInfoJson: JSON) -> Array<PhotoMetadata>? {
        let photoMetadataListJson = userInfoJson["recently_send_photo_urls"].arrayValue
        var photoMetadataList = Array<PhotoMetadata>()
        for photoMetadataJson in photoMetadataListJson {
            let url = photoMetadataJson["send_photo_url"].stringValue
            photoMetadataList.append(PhotoMetadata(url: url))
        }
        return photoMetadataList.count > 0 ? photoMetadataList : nil
    }
}
