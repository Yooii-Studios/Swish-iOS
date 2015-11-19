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
    case Unblock
    case Block
}

private let imageCache = NSCache.createWithMemoryWarningObserver()

private var canUseThumbnail: Bool {
    return DeviceHelper.devicePixelWidth <= DeviceHelper.IPhone6UIScreenPixelWidth
}

class Photo: Object {
    
    typealias ID = Int64
    
    static let InvalidId: Photo.ID = -1
    static let InvalidMessage = ""
    
    private static let InvalidName = ""
    private static let DefaultPhotoState = PhotoState.Waiting
    private static let DefaultChatRoomBlockState = ChatRoomBlockState.Unblock
    
    // MARK: - Attributes
    
    dynamic var id: Photo.ID = InvalidId
    dynamic var message = InvalidMessage
    dynamic var fileName = InvalidName
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
            return ChatRoomBlockState(rawValue: chatRoomBlockStateRaw) ?? Photo.DefaultChatRoomBlockState
        }
        set(newChatRoomBlockState) {
            chatRoomBlockStateRaw = newChatRoomBlockState.rawValue
        }
    }
    var arrivedLocation: CLLocation? {
        get {
            let hasArrivedLocation = !arrivedLatitude.isNaN || !arrivedLongitude.isNaN
            return hasArrivedLocation ? CLLocation(latitude: arrivedLatitude, longitude: arrivedLongitude) : nil
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
            return PhotoState(rawValue: photoStateRaw) ?? Photo.DefaultPhotoState
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
                optionalReceiver = receivedUserId != User.InvalidId
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
    
    final class func create(id: Photo.ID = InvalidId, message: String, departLocation: CLLocation) -> Photo {
        let photo = Photo(id: id)
        photo.message = message
        photo.departLocation = departLocation
        return photo
    }
    
    // MARK: - Realm support
    
    private dynamic var chatRoomBlockStateRaw = DefaultChatRoomBlockState.rawValue
    
    private dynamic var arrivedLatitude = CLLocationDegrees.NaN
    private dynamic var arrivedLongitude = CLLocationDegrees.NaN
    private dynamic var departLatitude = CLLocationDegrees.NaN
    private dynamic var departLongitude = CLLocationDegrees.NaN
    
    private dynamic var photoStateRaw = DefaultPhotoState.rawValue
    private dynamic var receivedUserId = User.InvalidId
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["hasBlockedChat", "chatRoomBlockState", "departLocation", "arrivedLocation", "photoState", "receiver"]
    }
}

func == (left: Photo, right: Photo) -> Bool {
    return left.id == right.id
}

// Image
extension Photo {
    
    final func loadImage(handler: (image: UIImage?) -> Void) {
        let tag = Timestamp.startAndGetTag()
        if let image = imageCache.objectForKey(fileName) as? UIImage {
            Timestamp.endWithTag(tag, additionalMessage: "with cache")
            handler(image: image)
            return
        }
        let path = FileHelper.filePathWithName(fileName, inDirectory: SubDirectory.Photos)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            let image = UIImage(contentsOfFile: path)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let image = image {
                    imageCache.setObject(image, forKey: self.fileName)
                }
                Timestamp.endWithTag(tag, additionalMessage: "without cache")
                
                handler(image: image)
            })
        })
    }
    
    final func saveImage(image: UIImage, handler: () -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.fileName = "\(NSDate().timeIntervalSince1970)"
            
            self.saveOriginalImage(image)
            if canUseThumbnail {
                self.saveThumbnailImage(image)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                handler()
            })
        }
    }
    
    private func saveOriginalImage(image: UIImage) {
        Photo.saveImage(image, withFileName: fileName)
    }
    
    private func saveThumbnailImage(image: UIImage) {
        Photo.saveImage(image.createResizedImage(image.size / 2), withFileName: "th_\(fileName)")
    }
    
    private class func saveImage(image: UIImage, withFileName fileName: String) {
        let imagePath = FileHelper.filePathWithName(fileName, inDirectory: SubDirectory.Photos)
        image.saveIntoPath(imagePath)
        imageCache.setObject(image, forKey: fileName)
    }
}
