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

enum ChatRoomBlockState: Int {
    case Unblock, Block
}

class Photo: Object {
    typealias ID = Int64
    static let invalidId: ID = -1
    static let invalidName = ""
    private static let defaultPhotoState = PhotoState.Waiting
    private static let defaultChatRoomBlockState = ChatRoomBlockState.Unblock
    
    // Mark: Attributes
    
    // required
    dynamic var id: ID = invalidId
    dynamic var fileName = invalidName
    dynamic var message = ""
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
    var departLocation: CLLocation {
        get {
            return CLLocation(latitude: departLatitude, longitude: departLongitude)
        }
        set {
            departLatitude = newValue.coordinate.latitude
            departLongitude = newValue.coordinate.longitude
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
    
    // backlink
    var sender: User {
        let userCandidate: User
        let meCandidates = linkingObjects(Me.self, forProperty: "photos")
        if meCandidates.count > 0 {
            userCandidate = meCandidates[0]
        } else {
            let otherCandidates = linkingObjects(OtherUser.self, forProperty: "photos")
            userCandidate = otherCandidates[0]
        }
        
        return userCandidate
    }
    
    // Mark: init
    
    // TODO: convert to protected when becames possible
    private convenience init(id: ID) {
        self.init()
        self.id = id
    }
    
    private convenience init(intId: Int) {
        self.init(id: ID(intId))
    }
    
    // Mark: Realm support
    
    // required
    private dynamic var chatRoomBlockStateRaw = defaultChatRoomBlockState.rawValue
    
    private dynamic var departLatitude = CLLocationDegrees.NaN
    private dynamic var departLongitude = CLLocationDegrees.NaN
    
    private dynamic var arrivedLatitude = CLLocationDegrees.NaN
    private dynamic var arrivedLongitude = CLLocationDegrees.NaN
    
    private dynamic var photoStateRaw = defaultPhotoState.rawValue
    private dynamic var receivedUserId = User.invalidId
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["hasBlockedChat", "chatRoomBlockState", "departLocation", "arrivedLocation", "photoState", "receiver"]
    }
    
    final class func create() -> Photo {
        return Photo()
    }
}

func == (left: Photo, right: Photo) -> Bool {
    return left.id == right.id
}
