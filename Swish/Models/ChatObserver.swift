//
//  ChatObserver.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 14..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit

struct ChatObserver {
    
    // KVO Streams
    private static var chatMessageStateStreams = Dictionary<ChatMessage, (Stream<AnyObject?>, Int)>()
    
    // MARK: - ChatMessage State
    
    static func observeChatMessageStateForChatMessage(chatMessage: ChatMessage, handler: ChatMessageSendState -> Void) {
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
    
    static func unobserveChatMessageStateWithChatMessage(chatMessage: ChatMessage) {
        chatMessageStateStreams[chatMessage]?.0.cancel()
        chatMessageStateStreams[chatMessage]?.1--
        
        if chatMessageStateStreams[chatMessage]?.1 <= 0 {
            chatMessageStateStreams[chatMessage] = nil
        }
        print("left chat state observers: \(chatMessageStateStreams.count)")
    }
}
