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
    private static var unreadMessageCountStreams = Dictionary<Photo.ID, (Stream<AnyObject?>, Int)>()
    private static var recentEventTimeStreams = Dictionary<Photo.ID, (Stream<AnyObject?>, Int)>()
    
    static func observeUnreadMessageCountStreamForPhoto(photo: Photo, handler: Int -> Void) {
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
    
    static func unobserveUnreadMessageCountStream(photoId: Photo.ID) {
        unreadMessageCountStreams[photoId]?.0.cancel()
        unreadMessageCountStreams[photoId]?.1--
        
        if unreadMessageCountStreams[photoId]?.1 <= 0 {
            unreadMessageCountStreams[photoId] = nil
        }
        print("left unread message count observers: \(unreadMessageCountStreams.count)")
    }
    
    static func observeRecentEventTimeStreamForPhotos(photos: [Photo], handler: (Photo.ID, Photo.EventTime) -> Void) {
        for photo in photos {
            observeRecentEventTimeStreamForPhoto(photo, handler: handler)
        }
    }
    
    static func observeRecentEventTimeStreamForPhoto(photo: Photo, handler: (Photo.ID, Photo.EventTime) -> Void) {
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
    
    static func unobserveRecentEventTimeStreams(photos: [Photo]) {
        for photo in photos {
            unobserveRecentEventTimeStream(photo.id)
        }
    }
    
    static func unobserveRecentEventTimeStream(photoId: Photo.ID) {
        recentEventTimeStreams[photoId]?.0.cancel()
        recentEventTimeStreams[photoId]?.1--
        
        if recentEventTimeStreams[photoId]?.1 <= 0 {
            recentEventTimeStreams[photoId] = nil
        }
        print("left recent event time observers: \(recentEventTimeStreams.count)")
    }
}
