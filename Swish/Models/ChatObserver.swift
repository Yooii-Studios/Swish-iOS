//
//  ChatObserver.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 14..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit

final class ChatObserver {
    
    // KVO Streams
    private static var _unreadMessageCountStreams = Dictionary<Photo.ID, (Stream<AnyObject?>, Int)>()
    private static var _chatMessageStateStreams = Dictionary<ChatMessage, (Stream<AnyObject?>, Int)>()
    
    final class func observeUnreadMessageCountStreamForPhoto(photo: Photo, handler: Int -> Void) {
        if _unreadMessageCountStreams[photo.id] == nil {
            _unreadMessageCountStreams[photo.id] = (KVO.startingStream(photo, "unreadMessageCount"), 1)
        } else {
            _unreadMessageCountStreams[photo.id]!.1++
        }
        print("left unread message count observers: \(_unreadMessageCountStreams.count)")
        _unreadMessageCountStreams[photo.id]!.0 ~> { unreadMessageCount in
            handler(unreadMessageCount as! Int)
        }
    }
    
    final class func observeChatMessageStateStream(chatMessage: ChatMessage, handler: ChatMessageSendState -> Void) {
        if _chatMessageStateStreams[chatMessage] == nil {
            _chatMessageStateStreams[chatMessage] = (KVO.startingStream(chatMessage, "stateRaw"), 1)
        } else {
            _chatMessageStateStreams[chatMessage]!.1++
        }
        print("left chat state observers: \(_chatMessageStateStreams.count)")
        _chatMessageStateStreams[chatMessage]!.0 ~> { rawState in
            handler(ChatMessageSendState(rawValue: rawState as! String)!)
        }
    }
    
    // TODO: count변경시 사진 정렬 위치 바꾸기 위한 스트림
    
    final class func unobserveUnreadMessageCountStream(photoId: Photo.ID) {
        _unreadMessageCountStreams[photoId]?.0.cancel()
        _unreadMessageCountStreams[photoId]?.1--
        
        if _unreadMessageCountStreams[photoId]?.1 <= 0 {
            _unreadMessageCountStreams[photoId] = nil
        }
        print("left unread message count observers: \(_unreadMessageCountStreams.count)")
    }
    
    final class func unobserveChatMessageStateStream(chatMessage: ChatMessage) {
        _chatMessageStateStreams[chatMessage]?.0.cancel()
        _chatMessageStateStreams[chatMessage]?.1--
        
        if _chatMessageStateStreams[chatMessage]?.1 <= 0 {
            _chatMessageStateStreams[chatMessage] = nil
        }
        print("left chat state observers: \(_chatMessageStateStreams.count)")
    }
}
