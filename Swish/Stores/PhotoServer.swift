//
//  PhotoServer.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

struct PhotoResponse {
    let user: OtherUser
    let photo: Photo
    let imageUrl: String
}

struct ServerPhotoState {
    let photoId: Photo.ID
    let state: PhotoState
    let deliveredLocation: CLLocation?
    let receivedUserId: User.ID?
    
    // 응답으로 들어오지만 사용되지 않는 정보. 향후 대비 가능성을 고려해 남겨둠.
    //    let receivedUserName: String?
    //    let receivedUserProfileImageUrl: String?
}

struct PhotoTrendsResult {
    let countryName: String
    let trendingPhotoResults: [TrendingPhotoResult]
    let fetchedTimeMilli: NSTimeInterval
}

struct TrendingPhotoResult {
    let owner: OtherUser
    let photo: Photo
    let imageUrl: String
}

final class PhotoServer {
    
    private static let BasePhotoUrl = SwishServer.Host + "/photos"
    private static let UpdatePhotoStateTagPrefix = "update_photo_state"
    private static let FetchPhotoStateTagPrefix = "get_photos_state"
    private static let UpdateBlockChatStateTagPrefix = "block_chat"
    private static let FetchPhotoTrendsTagPrefix = "weekly_photos"
    
    class func photoResponsesWith(userId: String, departLocation: CLLocation, photoCount: Int?,
        onSuccess: (photoResponses: Array<PhotoResponse>) -> (), onFail: FailCallback) {
            let params = photosParamWith(userId, departLocation: departLocation, photoCount: photoCount)
            let parser = { (resultJson: JSON) -> Array<PhotoResponse> in return photoResponsesFrom(resultJson) }
            let httpRequest = HttpRequest<Array<PhotoResponse>>(method: .GET, url: BasePhotoUrl, parameters: params,
                parser: parser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func photoStatesWith(userId: String,
        onSuccess: (serverPhotoState: Array<ServerPhotoState>) -> (), onFail: FailCallback) {
            let url = "\(BasePhotoUrl)/get_photos_state"
            let params = serverPhotoStatesParamWith(userId)
            let parser = { (resultJson: JSON) -> Array<ServerPhotoState> in return serverPhotoStatesFrom(resultJson) }
            let httpRequest = HttpRequest<Array<ServerPhotoState>>(method: .GET, url: url, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.tag = createFetchPhotoStateTag()
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func save(photo: Photo, userId: User.ID, image: UIImage, onSuccess: (id: Photo.ID) -> (), onFail: FailCallback) {
        saveParamWith(photo, userId: userId, image: image) { params in
            let parser = { (resultJson: JSON) -> Photo.ID in return serverPhotoIdFrom(resultJson) }
            let httpRequest = HttpRequest<Photo.ID>(method: .POST, url: BasePhotoUrl, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
        }
    }
    
    class func sendChatMessage(chatMessage: ChatMessage, onSuccess: DefaultSuccessCallback,
        onFail: FailCallback) {
            let url = "\(BasePhotoUrl)/\(chatMessage.photo.id)/send_message"
            let params = sendChatMessageParamWith(chatMessage)
            let httpRequest = HttpRequest<JSON>(method: .POST, url: url, parameters: params, parser: SwishServer.DefaultParser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func updatePhotoState(photoId: Photo.ID, state: PhotoState,
        onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
            let url = "\(BasePhotoUrl)/\(photoId)/update_photo_state"
            let params = updatePhotoStateParamWith(state)
            let httpRequest = HttpRequest<JSON>(method: .PUT, url: url, parameters: params, parser: SwishServer.DefaultParser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.tag = createUpdatePhotoStateTagWithPhotoId(photoId)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func updateBlockChatState(photoId: Photo.ID, state: ChatRoomBlockState, onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
        let url = "\(BasePhotoUrl)/\(photoId)/block_chat"
        let params = updateBlockChatStateParamWith(state)
        let httpRequest = HttpRequest<JSON>(method: .PUT, url: url, parameters: params, parser: SwishServer.DefaultParser, onSuccess: onSuccess, onFail: onFail)
        httpRequest.tag = createUpdateBlockChatStateTag()
        
        SwishServer.requestWith(httpRequest)
    }
    
    class func photoTrendsResult(onSuccess: (photoTrendsResult: PhotoTrendsResult) -> Void, onFail: FailCallback) {
        let url = "\(SwishServer.Host)/weekly_photos"
        let parser = { (resultJson: JSON) -> PhotoTrendsResult in return photoTrendsFromResult(resultJson) }
        let httpRequest = HttpRequest<PhotoTrendsResult>(method: .GET, url: url, parser: parser, onSuccess: onSuccess, onFail: onFail)
        httpRequest.tag = createFetchPhotoTrendsTag()
        
        SwishServer.requestWith(httpRequest)
    }
    
    // MARK: - Params
    
    private class func photosParamWith(userId: String, departLocation: CLLocation, photoCount: Int?) -> Param {
        var params = Param()
        params.updateValue(userId, forKey: "user_id")
        params.updateValue(departLocation.coordinate.latitude.description, forKey: "latitude")
        params.updateValue(departLocation.coordinate.longitude.description, forKey: "longitude")
        if let photoCount = photoCount {
            params.updateValue(photoCount.description, forKey: "request_photo_number")
        }
        
        return params
    }
    
    private class func serverPhotoStatesParamWith(userId: String) -> Param {
        return [ "user_id": userId ]
    }
    
    // ImageHelper.base64EncodedStringWith(image)에서 약 500ms의 running time확인, 예외적으로 dispatch_async 적용
    private class func saveParamWith(photo: Photo, userId: User.ID, image: UIImage, completion: (param: Param) -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let params: Param =  [
                "user_id": userId,
                "message": photo.message,
                "latitude": photo.departLocation.coordinate.latitude.description,
                "longitude": photo.departLocation.coordinate.longitude.description,
                "image_resource": image.base64EncodedString
            ]
            dispatch_async(dispatch_get_main_queue()) {
                completion(param: params)
            }
        }
    }
    
    private class func sendChatMessageParamWith(chatMessage: ChatMessage) -> Param {
        return [
            "sender_id": chatMessage.sender.id,
            "message": chatMessage.message
        ]
    }
    
    private class func updatePhotoStateParamWith(photoState: PhotoState) -> Param {
        return [
            "state": photoState.key.description
        ]
    }
    
    private class func updateBlockChatStateParamWith(state: ChatRoomBlockState) -> Param {
        return [
            "block_enabled": state == ChatRoomBlockState.Block ? "true" : "false"
        ]
    }
    
    // MARK: - Parsers
    
    private class func photoResponsesFrom(resultJson: JSON) -> Array<PhotoResponse> {
        var items = Array<PhotoResponse>()
        photoInfoFromResultJson(resultJson) { (photo, sender, imageUrl) -> Void in
            let item = PhotoResponse(user: sender, photo: photo, imageUrl: imageUrl)
            items.append(item)
        }
        return items
    }
    
    private class func serverPhotoStatesFrom(resultJson: JSON) -> Array<ServerPhotoState> {
        let photoStateJsonArray = resultJson["photos"].arrayValue
        
        var items = Array<ServerPhotoState>()
        for photoStateJson in photoStateJsonArray {
            let id = photoStateJson["id"].int64Value
            let stateKey = photoStateJson["state"].intValue
            let state = PhotoState.findWithKey(stateKey)
            var receivedUserId: User.ID?
            if let receivedUserJson = photoStateJson["user_info"].dictionary,
                let userId = receivedUserJson["id"]?.string {
                    receivedUserId = userId
                    // 응답으로 들어오지만 사용되지 않는 정보. 향후 대비 가능성을 고려해 남겨둠.
//                    let receivedUserJson = photoStateJson["user_info"]
//                    let userId = receivedUserJson["id"].stringValue
//                    let userName = receivedUserJson["name"].stringValue
//                    let userProfileImageUrl = receivedUserJson["profile_image_url"].stringValue
            }
            
            var location: CLLocation?
            if let locationJson = photoStateJson["delivered_location"].dictionary,
                let latitude = locationJson["latitude"]?.doubleValue,
                let longitude = locationJson["longitude"]?.doubleValue {
                    location = CLLocation(latitude: latitude, longitude: longitude)
            }
            
            let item = ServerPhotoState(photoId: id, state: state, deliveredLocation: location,
                receivedUserId: receivedUserId)
            items.append(item)
        }
        
        return items
    }
    
    private class func serverPhotoIdFrom(resultJson: JSON) -> Photo.ID {
        return resultJson["photo"]["id"].int64Value
    }
    
    private class func photoTrendsFromResult(resultJson: JSON) -> PhotoTrendsResult {
        var trendingPhotoResults = Array<TrendingPhotoResult>()
        photoInfoFromResultJson(resultJson) { (photo, sender, imageUrl) -> Void in
            let trendingPhoto = TrendingPhotoResult(owner: sender, photo: photo, imageUrl: imageUrl)
            trendingPhotoResults.append(trendingPhoto)
        }
        let countryName = resultJson["country"].stringValue
        
        return PhotoTrendsResult(countryName: countryName, trendingPhotoResults: trendingPhotoResults,
            fetchedTimeMilli: NSDate().timeIntervalSince1970)
    }
    
    private class func photoInfoFromResultJson(resultJson: JSON, handler: (photo: Photo, sender: OtherUser,
        imageUrl: String) -> Void) {
            let photosJsonArray = resultJson["photos"].arrayValue
            
            for photoJson in photosJsonArray {
                let senderJson = photoJson["sender"]
                let senderId = senderJson["id"].stringValue
                let sender = OtherUser.create(senderId) {
                    $0.name = senderJson["name"].stringValue
                    
                    $0.about = senderJson["about"].stringValue
                    $0.profileUrl = senderJson["profile_image_url"].stringValue
                    $0.level = senderJson["level"].intValue
                    
                    let activityRecordJson = senderJson["activity_record"]
                    $0.userActivityRecord = UserActivityRecord(
                        sentPhotoCount: activityRecordJson["upload_photo_count"].intValue,
                        likedPhotoCount: activityRecordJson["like_get_count"].intValue,
                        dislikedPhotoCount: activityRecordJson["dislike_get_count"].intValue)
                }
                
                let latitude = photoJson["latitude"].doubleValue
                let longitude = photoJson["longitude"].doubleValue
                let photoDepartLocation = CLLocation(latitude: latitude, longitude: longitude)
                let photoDepartCountry = photoJson["country"].stringValue
                
                let photoId = photoJson["id"].int64Value
                let photoMessage = photoJson["message"].stringValue
                let photo = Photo.create(photoId, message: photoMessage, departLocation: photoDepartLocation,
                    departCountry: photoDepartCountry)
                photo.photoState = .Delivered
                
                
                let imageUrl = photoJson["url"].stringValue
                
                handler(photo: photo, sender: sender, imageUrl: imageUrl)
            }
    }
    
    // MARK: - Helpers
    
    class func cancelUpdatePhotoStateWithPhotoId(photoId: Photo.ID) {
        SwishServer.instance.cancelWith(createUpdatePhotoStateTagWithPhotoId(photoId))
    }
    
    class func cancelFetchPhotoState() {
        SwishServer.instance.cancelWith(createFetchPhotoStateTag())
    }
    
    class func cancelUpdateBlockChatState() {
        SwishServer.instance.cancelWith(createUpdateBlockChatStateTag())
    }
    
    class func cancelFetchPhotoTrends() {
        SwishServer.instance.cancelWith(createFetchPhotoTrendsTag())
    }
    
    private class func createUpdatePhotoStateTagWithPhotoId(photoId: Photo.ID) -> String {
        return SwishServer.createTagWithPrefix(UpdatePhotoStateTagPrefix, postfix: "\(photoId)")
    }
    
    private class func createFetchPhotoStateTag() -> String {
        return SwishServer.createTagWithPrefix(FetchPhotoStateTagPrefix)
    }
    
    private class func createUpdateBlockChatStateTag() -> String {
        return SwishServer.createTagWithPrefix(UpdateBlockChatStateTagPrefix)
    }
    
    private class func createFetchPhotoTrendsTag() -> String {
        return SwishServer.createTagWithPrefix(FetchPhotoTrendsTagPrefix)
    }
}
