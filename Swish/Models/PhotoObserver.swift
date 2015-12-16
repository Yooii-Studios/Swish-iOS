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
    
    // TODO: count변경시 사진 정렬 위치 바꾸기 위한 스트림
}
