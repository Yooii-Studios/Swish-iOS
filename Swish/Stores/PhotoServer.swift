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
    
    // 응답으로 들어오지만 사용되지 않는 정보. 향후 대비 가능성을 고려해 남겨둠.
    //    let receivedUserId: User.ID?
    //    let receivedUserName: String?
    //    let receivedUserProfileImageUrl: String?
}

final class PhotoServer {
    private static let basePhotoUrl = SwishServer.host + "/photos"
    private static let updatePhotoStateTagPrefix = "update_photo_state"
    private static let fetchPhotoStateTagPrefix = "get_photos_state"
    private static let updateBlockChatStateTagPrefix = "block_chat"
    
    class func photoResponsesWith(userId: String, departLocation: CLLocation, photoCount: Int?,
        onSuccess: (photoResponses: Array<PhotoResponse>) -> (), onFail: FailCallback) {
            let params = photosParamWith(userId, departLocation: departLocation, photoCount: photoCount)
            let parser = { (resultJson: JSON) -> Array<PhotoResponse> in return photoResponsesFrom(resultJson) }
            let httpRequest = HttpRequest<Array<PhotoResponse>>(method: .GET, url: basePhotoUrl, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func photoStatesWith(userId: String,
        onSuccess: (serverPhotoState: Array<ServerPhotoState>) -> (), onFail: FailCallback) {
            let url = "\(basePhotoUrl)/get_photos_state"
            let params = serverPhotoStatesParamWith(userId)
            let parser = { (resultJson: JSON) -> Array<ServerPhotoState> in return serverPhotoStatesFrom(resultJson) }
            let httpRequest = HttpRequest<Array<ServerPhotoState>>(method: .GET, url: url, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.tag = createFetchPhotoStateTag()
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func save(photo: Photo, userId: User.ID, image: UIImage, onSuccess: (id: Photo.ID) -> (), onFail: FailCallback) {
        let params = saveParamWith(photo, userId: userId, image: image)
        let parser = { (resultJson: JSON) -> Photo.ID in return serverPhotoIdFrom(resultJson) }
        let httpRequest = HttpRequest<Photo.ID>(method: .POST, url: basePhotoUrl, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
        
        SwishServer.requestWith(httpRequest)
    }
    
    class func sendChatMessage(chatMessage: ChatMessage, onSuccess: DefaultSuccessCallback,
        onFail: FailCallback) {
            let url = "\(basePhotoUrl)/\(chatMessage.photo.id)/send_message"
            let params = sendChatMessageParamWith(chatMessage)
            let httpRequest = HttpRequest<JSON>(method: .POST, url: url, parameters: params, parser: SwishServer.defaultParser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func updatePhotoState(photoId: Photo.ID, state: PhotoState,
        onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
            let url = "\(basePhotoUrl)/\(photoId)/update_photo_state"
            let params = updatePhotoStateParamWith(state)
            let httpRequest = HttpRequest<JSON>(method: .PUT, url: url, parameters: params, parser: SwishServer.defaultParser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.tag = createUpdatePhotoStateTagWithPhotoId(photoId)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func updateBlockChatState(photoId: Photo.ID, state: ChatRoomBlockState, onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
        let url = "\(basePhotoUrl)/\(photoId)/block_chat"
        let params = updateBlockChatStateParamWith(state)
        let httpRequest = HttpRequest<JSON>(method: .PUT, url: url, parameters: params, parser: SwishServer.defaultParser, onSuccess: onSuccess, onFail: onFail)
        httpRequest.tag = createUpdateBlockChatStateTag()
        
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
    
    private class func saveParamWith(photo: Photo, userId: User.ID, image: UIImage) -> Param {
        return [
            "user_id": userId,
            "message": photo.message,
            "latitude": photo.departLocation.coordinate.latitude.description,
            "longitude": photo.departLocation.coordinate.longitude.description,
            "image_resource": ImageHelper.base64EncodedStringWith(image)
        ]
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
        let photosJsonArray = resultJson["photos"].arrayValue
        
        var items = Array<PhotoResponse>()
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
            let location = CLLocation(latitude: latitude, longitude: longitude)

            let photo = Photo()
            photo.id = photoJson["id"].int64Value
            photo.message = photoJson["message"].stringValue
            photo.departLocation = location
            let imageUrl = photoJson["url"].stringValue
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
            
            var location: CLLocation?
            if state == .Delivered || state == .Liked || state == .Disliked {
                let locationJson = photoStateJson["delivered_location"]
                let latitude = locationJson["latitude"].doubleValue
                let longitude = locationJson["longitude"].doubleValue
                location = CLLocation(latitude: latitude, longitude: longitude)
            }
            
            // 응답으로 들어오지만 사용되지 않는 정보. 향후 대비 가능성을 고려해 남겨둠.
//            let receivedUserJson = photoStateJson["user_info"]
//            let userId = receivedUserJson["id"].stringValue
//            let userName = receivedUserJson["name"].stringValue
//            let userProfileImageUrl = receivedUserJson["profile_image_url"].stringValue
            
            let item = ServerPhotoState(photoId: id, state: state, deliveredLocation: location)
            items.append(item)
        }
        
        return items
    }
    
    private class func serverPhotoIdFrom(resultJson: JSON) -> Photo.ID {
        return resultJson["photo"]["id"].int64Value
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
    
    private class func createUpdatePhotoStateTagWithPhotoId(photoId: Photo.ID) -> String {
        return SwishServer.createTagWithPrefix(updatePhotoStateTagPrefix, postfix: "\(photoId)")
    }
    
    private class func createFetchPhotoStateTag() -> String {
        return SwishServer.createTagWithPrefix(fetchPhotoStateTagPrefix)
    }
    
    private class func createUpdateBlockChatStateTag() -> String {
        return SwishServer.createTagWithPrefix(updateBlockChatStateTagPrefix)
    }
}
