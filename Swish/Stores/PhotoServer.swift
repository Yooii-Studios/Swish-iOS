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

final class PhotoServer {
    private static let basePhotoUrl = SwishServer.host + "/photos"
    
    class func photoResponsesWith(userId: String, departLocation: CLLocation, photoCount: Int?,
        onSuccess: (photos: Array<PhotoResponse>) -> (), onFail: FailCallback) {
            let params = photosParamWith(userId, departLocation: departLocation, photoCount: photoCount)
            let parser = { (resultJson: JSON) -> Array<PhotoResponse> in return photoResponsesFrom(resultJson) }
            let httpRequest = HttpRequest<Array<PhotoResponse>>(method: .GET, url: basePhotoUrl, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func photoStatesWith(userId: String,
        onSuccess: (photoStates: Array<ServerPhotoState>) -> (), onFail: FailCallback) {
            let url = "\(basePhotoUrl)/get_photos_state"
            let params = serverPhotoStatesParamWith(userId)
            let parser = { (resultJson: JSON) -> Array<ServerPhotoState> in return serverPhotoStatesFrom(resultJson) }
            let httpRequest = HttpRequest<Array<ServerPhotoState>>(method: .GET, url: url, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            
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
            
            SwishServer.requestWith(httpRequest)
    }
    
    class func blockChat(photoId: Photo.ID, onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
        updateBlockChatState(photoId, block: true, onSuccess: onSuccess, onFail: onFail)
    }
    
    class func unblockChat(photoId: Photo.ID, onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
        updateBlockChatState(photoId, block: false, onSuccess: onSuccess, onFail: onFail)
    }
    
    private class func updateBlockChatState(photoId: Photo.ID, block: Bool, onSuccess: DefaultSuccessCallback, onFail: FailCallback) {
        let url = "\(basePhotoUrl)/\(photoId)/block_chat"
        let params = updateBlockChatStateParamWith(block)
        let httpRequest = HttpRequest<JSON>(method: .PUT, url: url, parameters: params, parser: SwishServer.defaultParser, onSuccess: onSuccess, onFail: onFail)
        
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
    
    private class func updateBlockChatStateParamWith(blocked: Bool) -> Param {
        return [
            "block_enabled": blocked.description
        ]
    }
    
    // MARK: - Parsers
    
    private class func photoResponsesFrom(resultJson: JSON) -> Array<PhotoResponse> {
        let photosJsonArray = resultJson["photos"].arrayValue
        
        var items = Array<PhotoResponse>()
        for photoJson in photosJsonArray {
            let userId = photoJson["sender"]["id"].stringValue
            
            let latitude = photoJson["latitude"].doubleValue
            let longitude = photoJson["longitude"].doubleValue
            let location = CLLocation(latitude: latitude, longitude: longitude)

            let photo = Photo()
            photo.id = photoJson["id"].int64Value
            photo.message = photoJson["message"].stringValue
            photo.departLocation = location
            let imageUrl = photoJson["url"].stringValue
            let item = PhotoResponse(userId: userId, photo: photo, imageUrl: imageUrl)
            
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
            
            let locationJson = photoStateJson["delivered_location"]
            let latitude = locationJson["latitude"].doubleValue
            let longitude = locationJson["longitude"].doubleValue
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            let receivedUserJson = photoStateJson["user_info"]
            let userId = receivedUserJson["id"].stringValue
            let userName = receivedUserJson["name"].stringValue
            let userProfileImageUrl = receivedUserJson["profile_image_url"].stringValue
            
            let item = ServerPhotoState(
                photoId: id, state: state, deliveredLocation: location,
                receivedUserId: userId, receivedUserName: userName, receivedUserProfileImageUrl: userProfileImageUrl)
            items.append(item)
        }
        
        return items
    }
    
    private class func serverPhotoIdFrom(resultJson: JSON) -> Photo.ID {
        return resultJson["photo"]["id"].int64Value
    }
}

struct PhotoResponse {
    let userId: User.ID
    let photo: Photo
    let imageUrl: String
}

struct ServerPhotoState {
    let photoId: Photo.ID
    let state: PhotoState
    let deliveredLocation: CLLocation
    let receivedUserId: User.ID
    let receivedUserName: String
    let receivedUserProfileImageUrl: String
}
