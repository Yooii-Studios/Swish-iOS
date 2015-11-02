//
//  Photo.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 3..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import SwiftyJSON

let invalidPhotoId: Photo.ID = -1
let invalidPhotoMessage = ""

enum ChatRoomBlockState: Int {
    
    case Unblock, Block
}

class Photo: Object {
    
    typealias ID = Int64
    
    static let invalidName = ""
    
    private static let defaultPhotoState = PhotoState.Waiting
    private static let defaultChatRoomBlockState = ChatRoomBlockState.Unblock
    
    // MARK: - Attributes
    
    dynamic var id: Photo.ID = invalidPhotoId
    dynamic var message = invalidPhotoMessage
    dynamic var fileName = invalidName
    dynamic var unreadMessageCount = 0
    dynamic var hasOpenedChatRoom = false
    let chatMessages = List<ChatMessage>()
    var hasBlockedChat: Bool {
        get {
            return chatRoomBlockState == .Block
        }
        set(newHasBlockedChat) {
            chatRoomBlockState = newHasBlockedChat ? .Block : .Unblock
        }
    }
    var chatRoomBlockState: ChatRoomBlockState {
        get {
            return ChatRoomBlockState(rawValue: chatRoomBlockStateRaw) ?? Photo.defaultChatRoomBlockState
        }
        set(newChatRoomBlockState) {
            chatRoomBlockStateRaw = newChatRoomBlockState.rawValue
        }
    }
    var arrivedLocation: CLLocation? {
        get {
            let hasArrivedLocation =
            arrivedLatitude != CLLocationDegrees.NaN || arrivedLongitude != CLLocationDegrees.NaN
            return hasArrivedLocation
                ? CLLocation(latitude: arrivedLatitude, longitude: arrivedLongitude) : nil
        }
        
        set {
            arrivedLatitude = newValue?.coordinate.latitude ?? CLLocationDegrees.NaN
            arrivedLongitude = newValue?.coordinate.longitude ?? CLLocationDegrees.NaN
        }
    }
    var departLocation: CLLocation {
        get {
            return CLLocation(latitude: departLatitude, longitude: departLongitude)
        }
        set {
            departLatitude = newValue.coordinate.latitude
            departLongitude = newValue.coordinate.longitude
        }
    }
    var photoState: PhotoState {
        get {
            return PhotoState(rawValue: photoStateRaw) ?? Photo.defaultPhotoState
        }
        set(newPhotoState) {
            photoStateRaw = newPhotoState.rawValue
        }
    }
    var receiver: User? {
        get {
            let me = SwishDatabase.me()
            var optionalReceiver: User?
            if sender == SwishDatabase.me() {
                optionalReceiver = receivedUserId != User.invalidId
                ? SwishDatabase.otherUser(receivedUserId) : nil
            } else {
                optionalReceiver = me
            }
            return optionalReceiver
        }
        set {
            receivedUserId = newValue!.id
        }
    }
    
    // MARK: - Realm backlink
    
    var sender: User {
        return PhotoHelper.senderWithPhoto(self)
    }
    
    // MARK: - Init
    
    // TODO: convert to protected when becames possible
    private convenience init(id: ID) {
        self.init()
        self.id = id
    }
    
    private convenience init(intId: Int) {
        self.init(id: ID(intId))
    }
    
    // MARK: - Realm support
    
    private dynamic var chatRoomBlockStateRaw = defaultChatRoomBlockState.rawValue
    
    private dynamic var arrivedLatitude = CLLocationDegrees.NaN
    private dynamic var arrivedLongitude = CLLocationDegrees.NaN
    private dynamic var departLatitude = CLLocationDegrees.NaN
    private dynamic var departLongitude = CLLocationDegrees.NaN
    
    private dynamic var photoStateRaw = defaultPhotoState.rawValue
    private dynamic var receivedUserId = User.invalidId
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["hasBlockedChat", "chatRoomBlockState", "departLocation", "arrivedLocation", "photoState", "receiver"]
    }
    
    final class func create(id: Photo.ID = invalidPhotoId, message: String, departLocation: CLLocation) -> Photo {
        let photo = Photo(id: id)
        photo.message = message
        photo.departLocation = departLocation
        return photo
    }
}

func == (left: Photo, right: Photo) -> Bool {
    return left.id == right.id
}
