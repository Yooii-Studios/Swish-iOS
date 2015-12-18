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
import SwiftTask

struct ChatObserver: RealmObjectObservable {
    
    // MARK: - ChatMessage State
    
    static func observeChatMessageStateForChatMessage(chatMessage: ChatMessage, owner: NSObject,
        handler: ChatMessageSendState -> Void) -> Canceller? {
            return startingStream(chatMessage, property: "stateRaw", owner: owner) {
                handler(ChatMessageSendState(rawValue: $0 as! String)!)
            }
    }
}
