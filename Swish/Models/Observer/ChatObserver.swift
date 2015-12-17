//
//  ChatObserver.swift
//   Usage: PhotoObserver.swift 참조
//
//  Swish
//
//  Created by 정동현 on 2015. 12. 14..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit

struct ChatObserver: RealmObjectObservable {
    
    private typealias ChatMessageStreams = BaseStreams<ChatMessage, AnyObject?>.T
    
    // KVO Streams
    private static var chatMessageStateStreams = ChatMessageStreams()
    
    // MARK: - ChatMessage State
    
    static func observeChatMessageStateForChatMessage(chatMessage: ChatMessage, handler: ChatMessageSendState -> Void) {
        observeWithKey(chatMessage, intoStreams: &chatMessageStateStreams,
            createStreamClosure: { return KVO.startingStream(chatMessage, "stateRaw") },
            handler: { handler(ChatMessageSendState(rawValue: $0 as! String)!) })
    }
    
    static func unobserveChatMessageStateWithChatMessage(chatMessage: ChatMessage) {
        unobserveWithKey(chatMessage, fromStream: &chatMessageStateStreams)
    }
}
