//
//  PhotoObserver.swift
//   Usage:
//    1. Observe / Unobserve 등록
//    ex.1) View Controller
//      override func viewDidLoad() {
//          super.viewDidLoad()
//          ...
//          PhotoObserver.observeUnreadMessageCountForPhoto(photo) { [unowned self] unreadCount in
//              print("\(self.photoId)s unread message count: \(unreadCount)")
//          }
//      }
//      
//      deinit {
//          PhotoObserver.unobserveUnreadMessageCountWithPhotoId(photoId)
//      }
//
//    ex.2) UICollectionViewCell: PhotoViewCell.swift 참조
//
//  Swish
//
//  Created by 정동현 on 2015. 12. 16..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit

struct PhotoObserver: RealmObjectObservable {
    
    private typealias PhotoStreams = BaseStreams<Photo.ID, AnyObject?>.T
    private typealias DetailedPhotoStreams = BaseStreams<Photo.ID, (AnyObject?, NSKeyValueChange, NSIndexSet?)>.T
    
    // KVO Streams
    private static var unreadMessageCountStreams = PhotoStreams()
    private static var chatMessagesStreams = DetailedPhotoStreams()
    private static var photoStateStreams = PhotoStreams()
    private static var recentEventTimeStreams = PhotoStreams()
    
    // MARK: - Unread Message Count
    
    static func observeUnreadMessageCountForPhoto(photo: Photo, handler: Int -> Void) {
        observeWithKey(photo.id, intoStreams: &unreadMessageCountStreams,
            createStreamClosure: { return KVO.startingStream(photo, "unreadMessageCount") },
            handler: { handler($0 as! Int) })
    }
    
    static func unobserveUnreadMessageCountWithPhotoId(photoId: Photo.ID) {
        unobserveWithKey(photoId, fromStream: &unreadMessageCountStreams)
    }
    
    // MARK: - ChatMessages
    
    static func observeChatMessagesForPhoto(photo: Photo, handler: (index: Int) -> Void) {
        observeWithKey(photo.id, intoStreams: &chatMessagesStreams,
            createStreamClosure: { return KVO.detailedStream(photo, "chatMessages") },
            handler: { _, operation, indexSet in
                guard let indexSet = indexSet where operation == .Insertion else {
                    return
                }
                handler(index: indexSet.lastIndex)
        })
    }
    
    static func unobserveChatMessagesWithPhotoId(photoId: Photo.ID) {
        unobserveWithKey(photoId, fromStream: &chatMessagesStreams)
    }
    
    // MARK: - Photo State
    
    static func observePhotoStateForPhotos(photos: [Photo], handler: (id: Photo.ID, state: PhotoState) -> Void) {
        for photo in photos {
            observePhotoStateForPhoto(photo, handler: handler)
        }
    }
    
    static func observePhotoStateForPhoto(photo: Photo, handler: (id: Photo.ID, state: PhotoState) -> Void) {
        observeWithKey(photo.id, intoStreams: &photoStateStreams,
            createStreamClosure: { return KVO.stream(photo, "photoStateRaw") },
            handler: { handler(id: photo.id, state: PhotoState(rawValue: $0 as! String)!) })
    }
    
    static func unobservePhotoStateForPhotos(photos: [Photo]?) {
        guard let photos = photos else {
            return
        }
        
        for photo in photos {
            unobservePhotoStateWithPhotoId(photo.id)
        }
    }
    
    static func unobservePhotoStateWithPhotoId(photoId: Photo.ID) {
        unobserveWithKey(photoId, fromStream: &photoStateStreams)
    }
    
    // MARK: - Recent Event Time
    
    static func observeRecentEventTimeForPhotos(photos: [Photo], handler: (Photo.ID, Photo.EventTime) -> Void) {
        for photo in photos {
            observeRecentEventTimeForPhoto(photo, handler: handler)
        }
    }
    
    private static func observeRecentEventTimeForPhoto(photo: Photo, handler: (Photo.ID, Photo.EventTime) -> Void) {
        observeWithKey(photo.id, intoStreams: &recentEventTimeStreams,
            createStreamClosure: { return KVO.stream(photo, "recentEventTime") },
            handler: { handler(photo.id, $0 as! Photo.EventTime) })
    }
    
    static func unobserveRecentEventTimeForPhotos(photos: [Photo]?) {
        guard let photos = photos else {
            return
        }
        
        for photo in photos {
            unobserveRecentEventTimeWithPhotoId(photo.id)
        }
    }
    
    private static func unobserveRecentEventTimeWithPhotoId(photoId: Photo.ID) {
        unobserveWithKey(photoId, fromStream: &recentEventTimeStreams)
    }
}
