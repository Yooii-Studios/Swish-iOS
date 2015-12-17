//
//  PhotoObserver.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 16..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit

struct PhotoObserver {
    
    // KVO Streams
    // TODO: refactor(typealias + reduce repetition)
    private static var unreadMessageCountStreams = Dictionary<Photo.ID, (Stream<AnyObject?>, Int)>()
    private static var chatMessagesStreams = Dictionary<Photo.ID, (Stream<(AnyObject?, NSKeyValueChange, NSIndexSet?)>, Int)>()
    private static var photoStateStreams = Dictionary<Photo.ID, (Stream<AnyObject?>, Int)>()
    private static var recentEventTimeStreams = Dictionary<Photo.ID, (Stream<AnyObject?>, Int)>()
    
    // MARK: - Unread Message Count
    
    static func observeUnreadMessageCountForPhoto(photo: Photo, handler: Int -> Void) {
        if unreadMessageCountStreams[photo.id] == nil {
            unreadMessageCountStreams[photo.id] = (KVO.startingStream(photo, "unreadMessageCount"), 1)
        } else {
            unreadMessageCountStreams[photo.id]!.1++
        }
        print("left unread message count observers: \(unreadMessageCountStreams.count)")
        unreadMessageCountStreams[photo.id]!.0 ~> { unreadMessageCount in
            handler(unreadMessageCount as! Int)
        }
    }
    
    static func unobserveUnreadMessageCountWithPhotoId(photoId: Photo.ID) {
        unreadMessageCountStreams[photoId]?.0.cancel()
        unreadMessageCountStreams[photoId]?.1--
        
        if unreadMessageCountStreams[photoId]?.1 <= 0 {
            unreadMessageCountStreams[photoId] = nil
        }
        print("left unread message count observers: \(unreadMessageCountStreams.count)")
    }
    
    // MARK: - ChatMessages
    
    static func observeChatMessagesForPhoto(photo: Photo, handler: (index: Int) -> Void) {
        if chatMessagesStreams[photo.id] == nil {
            chatMessagesStreams[photo.id] = (KVO.detailedStream(photo, "chatMessages"), 1)
        } else {
            chatMessagesStreams[photo.id]!.1++
        }
        print("left chat message observers: \(chatMessagesStreams.count)")
        chatMessagesStreams[photo.id]!.0 ~> { changedItem, operation, indexSet in
            guard let indexSet = indexSet where operation == .Insertion else {
                return
            }
            handler(index: indexSet.lastIndex)
        }
    }
    
    static func unobserveChatMessagesWithPhotoId(photoId: Photo.ID) {
        chatMessagesStreams[photoId]?.0.cancel()
        chatMessagesStreams[photoId]?.1--
        
        if chatMessagesStreams[photoId]?.1 <= 0 {
            chatMessagesStreams[photoId] = nil
        }
        print("left chat message observers: \(chatMessagesStreams.count)")
    }
    
    // MARK: - Photo State
    
    static func observePhotoStateForPhotos(photos: [Photo], handler: (id: Photo.ID, state: PhotoState) -> Void) {
        for photo in photos {
            observePhotoStateForPhoto(photo, handler: handler)
        }
    }
    
    static func observePhotoStateForPhoto(photo: Photo, handler: (id: Photo.ID, state: PhotoState) -> Void) {
        if photoStateStreams[photo.id] == nil {
            photoStateStreams[photo.id] = (KVO.stream(photo, "photoStateRaw"), 1)
        } else {
            photoStateStreams[photo.id]!.1++
        }
        print("left photo state observers: \(photoStateStreams.count)")
        photoStateStreams[photo.id]!.0 ~> { photoStateRaw in
            handler(id: photo.id, state: PhotoState(rawValue: photoStateRaw as! String)!)
        }
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
        photoStateStreams[photoId]?.0.cancel()
        photoStateStreams[photoId]?.1--
        
        if photoStateStreams[photoId]?.1 <= 0 {
            photoStateStreams[photoId] = nil
        }
        print("left photo state observers: \(photoStateStreams.count)")
    }
    
    // MARK: - Recent Event Time
    
    static func observeRecentEventTimeForPhotos(photos: [Photo], handler: (Photo.ID, Photo.EventTime) -> Void) {
        for photo in photos {
            observeRecentEventTimeForPhoto(photo, handler: handler)
        }
    }
    
    private static func observeRecentEventTimeForPhoto(photo: Photo, handler: (Photo.ID, Photo.EventTime) -> Void) {
        if recentEventTimeStreams[photo.id] == nil {
            recentEventTimeStreams[photo.id] = (KVO.stream(photo, "recentEventTime"), 1)
        } else {
            recentEventTimeStreams[photo.id]!.1++
        }
        print("left recent event time observers: \(recentEventTimeStreams.count)")
        recentEventTimeStreams[photo.id]!.0 ~> { eventTime in
            handler(photo.id, eventTime as! Photo.EventTime)
        }
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
        recentEventTimeStreams[photoId]?.0.cancel()
        recentEventTimeStreams[photoId]?.1--
        
        if recentEventTimeStreams[photoId]?.1 <= 0 {
            recentEventTimeStreams[photoId] = nil
        }
        print("left recent event time observers: \(recentEventTimeStreams.count)")
    }
}
