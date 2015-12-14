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
    return DeviceHelper.devicePixelWidth <= DeviceHelper.iPhone6UIScreenPixelWidth
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
            if isSentPhoto {
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
    var isSentPhoto: Bool {
        return sender == SwishDatabase.me()
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

// MARK: - Image extension
extension Photo {
    
    enum ImageType {
        case Original
        case Thumbnail
    }
    
    // Image Context를 사용해 그리는 로직이라 추상화를 낮추는 것이 가독성을 떨어뜨리는 일이라 판단, 주석으로 흐름을 구분
    var mapAnnotationImage: UIImage {
        let markerImage = UIImage(named: "ic_map_photo_marker")!
        let markerImageSize = markerImage.size
        let markerImageRect = CGRectMake(0, 0, markerImageSize.width, markerImageSize.height)
        
        // Start image context & defer end image context
        UIGraphicsBeginImageContext(markerImageSize)
        defer { UIGraphicsEndImageContext() }
        
        // Draw marker image
        markerImage.drawInRect(markerImageRect)
        
        // Draw photo image
        let fileName = thumbnailFileName != nil ? thumbnailFileName! : self.fileName
        if let photoImage = Photo.loadImageWithFileName(fileName) {
            let smallPadding: CGFloat = 4
            let largePadding: CGFloat = 15
            
            let photoImageRect = CGRectMake(smallPadding, smallPadding,
                markerImageSize.width - 2 * smallPadding, markerImageSize.height - (smallPadding + largePadding))
            
            photoImage.drawInRect(photoImageRect)
        }
        
        // Retrieve result
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private final var thumbnailFileName: String? {
        return canUseThumbnail ? "th_\(fileName)" : nil
    }
    
    // MARK: - Save
    
    final func saveImage(image: UIImage, handler: () -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.fileName = "\(NSDate().timeIntervalSince1970)"
            
            self.saveOriginalImage(image)
            self.saveThumbnailImage(image)
            
            dispatch_async(dispatch_get_main_queue(), {
                handler()
            })
        }
    }
    
    private func saveOriginalImage(image: UIImage) {
        Photo.saveImage(image, withFileName: fileName)
    }
    
    private func saveThumbnailImage(image: UIImage) {
        if canUseThumbnail {
            Photo.saveImage(image.createResizedImage(image.size / 2), withFileName: thumbnailFileName!)
        }
    }
    
    private class func saveImage(image: UIImage, withFileName fileName: String) {
        let imagePath = FileHelper.filePathWithName(fileName, inDirectory: SubDirectory.Photos)
        image.saveIntoPath(imagePath)
        imageCache.setObject(image, forKey: fileName)
    }
    
    // MARK: - Load
    
    final func loadImage(imageType imageType: ImageType = .Original, handler: (image: UIImage?) -> Void) {
        if imageType == .Thumbnail, let thumbnailFileName = thumbnailFileName {
            Photo.loadImageWithFileName(thumbnailFileName, handler: handler)
        } else {
            Photo.loadImageWithFileName(fileName, handler: handler)
        }
    }
    
    private class func loadImageWithFileName(fileName: String, handler: (image: UIImage?) -> Void) {
        let tag = Timestamp.startAndGetTag()
        if let image = imageCache.objectForKey(fileName) as? UIImage {
            Timestamp.endWithTag(tag, additionalMessage: "with cache")
            handler(image: image)
            return
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            let image = loadImageWithFileName(fileName)
            
            dispatch_async(dispatch_get_main_queue(), {
                if let image = image {
                    imageCache.setObject(image, forKey: fileName)
                }
                Timestamp.endWithTag(tag, additionalMessage: "without cache")
                
                handler(image: image)
            })
        })
    }
    
    private class func loadImageWithFileName(fileName: String) -> UIImage? {
        let path = FileHelper.filePathWithName(fileName, inDirectory: SubDirectory.Photos)
        return UIImage(contentsOfFile: path)
    }
}

// MARK: - Delivered distance extension

enum DistanceUnit: String {
    
    case Kilometers = "km"
    case Miles = "mi"
    
    static var currentUnit: DistanceUnit {
        let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        
        return countryCode == nil || countryCode! != "US" ? Kilometers : Miles
    }
}

extension Photo {
    
    var deliveredDistanceString: String? {
        if let deliveredDistance = deliveredDistance {
            return "\(deliveredDistance) \(DistanceUnit.currentUnit.rawValue)"
        } else {
            // TODO: 로컬라이징 필요
            return "Your photo is still en route."
        }
    }
    
    private var deliveredDistance: Int? {
        guard let arrivedLocation = arrivedLocation else {
            return nil
        }
        let distanceInMeter = departLocation.distanceFromLocation(arrivedLocation)
        
        var distance = DistanceUnit.currentUnit == .Kilometers ? distanceInMeter.inKilometers : distanceInMeter.inMiles
        if distance < 1 {
            distance = 1
        }
        
        return Int(distance)
    }
}

private extension CLLocationDistance {
    
    var inKilometers: CLLocationDistance {
        return self / 1000
    }
    
    var inMiles: CLLocationDistance {
        return self * 0.000621371
    }
}
