//
//  PhotoObserver.swift
//   Usage:
//    1. Observe 등록
//    ex.1) View Controller
//      override func viewDidLoad() {
//          super.viewDidLoad()
//          ...
//          PhotoObserver.observeUnreadMessageCountForPhoto(photo) { [unowned self] unreadCount in
//              print("\(self.photoId)s unread message count: \(unreadCount)")
//          }
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
import SwiftTask

struct PhotoObserver: RealmObjectObservable {
    
    // MARK: - Unread Message Count
    
    static func observeUnreadMessageCountForPhoto(photo: Photo, owner: NSObject, handler: Int -> Void) -> Canceller? {
        return startingStream(photo, property: "unreadMessageCount", owner: owner) {
            handler($0 as! Int)
        }
    }
    
    // MARK: - ChatMessages
    
    static func observeChatMessagesForPhoto(photo: Photo, owner: NSObject, handler: (index: Int) -> Void) -> Canceller? {
        return detailedStream(photo, property: "chatMessages", owner: owner) { _, operation, indexSet in
            guard let indexSet = indexSet where operation == .Insertion else {
                return
            }
            handler(index: indexSet.lastIndex)
        }
    }
    
    // MARK: - Photo State
    
    static func observePhotoStateForPhotos(photos: [Photo], owner: NSObject,
        handler: (id: Photo.ID, state: PhotoState) -> Void) {
            for photo in photos {
                observePhotoStateForPhoto(photo, owner: owner, handler: handler)
            }
    }
    
    static func observePhotoStateForPhoto(photo: Photo, owner: NSObject,
        handler: (id: Photo.ID, state: PhotoState) -> Void) -> Canceller? {
            return stream(photo, property: "photoStateRaw", owner: owner) {
                handler(id: photo.id, state: PhotoState.findWithKey($0 as! Int))
            }
    }
    
    // MARK: - Recent Event Time
    
    static func observeRecentEventTimeForPhotos(photos: [Photo], owner: NSObject,
        handler: (Photo.ID, Photo.EventTime) -> Void) {
            for photo in photos {
                observeRecentEventTimeForPhoto(photo, owner: owner, handler: handler)
            }
    }
    
    private static func observeRecentEventTimeForPhoto(photo: Photo, owner: NSObject,
        handler: (Photo.ID, Photo.EventTime) -> Void) -> Canceller? {
            return stream(photo, property: "recentEventTime", owner: owner) {
                handler(photo.id, $0 as! Photo.EventTime)
            }
    }
}
