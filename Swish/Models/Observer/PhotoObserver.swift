//
//  PhotoObserver.swift
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
        print("left unread message count observers: \(unreadMessageCountStreams.count)")
    }
    
    static func unobserveUnreadMessageCountWithPhotoId(photoId: Photo.ID) {
        unobserveWithKey(photoId, fromStream: &unreadMessageCountStreams)
        print("left unread message count observers: \(unreadMessageCountStreams.count)")
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
        print("left chat message observers: \(chatMessagesStreams.count)")
    }
    
    static func unobserveChatMessagesWithPhotoId(photoId: Photo.ID) {
        unobserveWithKey(photoId, fromStream: &chatMessagesStreams)
        print("left chat message observers: \(chatMessagesStreams.count)")
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
        print("left photo state observers: \(photoStateStreams.count)")
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
        print("left photo state observers: \(photoStateStreams.count)")
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
        print("left recent event time observers: \(recentEventTimeStreams.count)")
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
        print("left recent event time observers: \(recentEventTimeStreams.count)")
    }
}
