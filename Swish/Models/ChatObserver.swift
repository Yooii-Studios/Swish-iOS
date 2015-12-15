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
    private static var unreadMessageCountStreams = Dictionary<Photo.ID, (Stream<AnyObject?>, Int)>()
    private static var chatMessageStateStreams = Dictionary<ChatMessage, (Stream<AnyObject?>, Int)>()
    
    final class func observeUnreadMessageCountStreamForPhoto(photo: Photo, handler: Int -> Void) {
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
    
    final class func observeChatMessageStateStream(chatMessage: ChatMessage, handler: ChatMessageSendState -> Void) {
        if chatMessageStateStreams[chatMessage] == nil {
            chatMessageStateStreams[chatMessage] = (KVO.startingStream(chatMessage, "stateRaw"), 1)
        } else {
            chatMessageStateStreams[chatMessage]!.1++
        }
        print("left chat state observers: \(chatMessageStateStreams.count)")
        chatMessageStateStreams[chatMessage]!.0 ~> { rawState in
            handler(ChatMessageSendState(rawValue: rawState as! String)!)
        }
    }
    
    // TODO: count변경시 사진 정렬 위치 바꾸기 위한 스트림
    
    final class func unobserveUnreadMessageCountStream(photoId: Photo.ID) {
        unreadMessageCountStreams[photoId]?.0.cancel()
        unreadMessageCountStreams[photoId]?.1--
        
        if unreadMessageCountStreams[photoId]?.1 <= 0 {
            unreadMessageCountStreams[photoId] = nil
        }
        print("left unread message count observers: \(unreadMessageCountStreams.count)")
    }
    
    final class func unobserveChatMessageStateStream(chatMessage: ChatMessage) {
        chatMessageStateStreams[chatMessage]?.0.cancel()
        chatMessageStateStreams[chatMessage]?.1--
        
        if chatMessageStateStreams[chatMessage]?.1 <= 0 {
            chatMessageStateStreams[chatMessage] = nil
        }
        print("left chat state observers: \(chatMessageStateStreams.count)")
    }
}
