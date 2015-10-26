//
//  ChatMessageSender.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 26..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

protocol ChatMessageSender {
    
    var photoId: Photo.ID { get }
    
    func handleSendChatMessageResult(chatMessage: ChatMessage, chatMessageSendState: ChatMessageSendState)
}

extension ChatMessageSender where Self: UIViewController {
    
    final func sendChatMessage(chatMessage: ChatMessage) {
        saveChatMessage(chatMessage)
        sendChatMessageInternal(chatMessage)
    }
    
    final func resendChatmessage(chatMessage: ChatMessage) {
        updateMessageSendState(chatMessage, state: .Sending)
        sendChatMessageInternal(chatMessage)
    }
    
    private func sendChatMessageInternal(chatMessage: ChatMessage) {
        PhotoServer.sendChatMessage(chatMessage, onSuccess: { (result) -> () in
            self.handleResult(chatMessage, state: .Success)
            }, onFail: { (error) -> Void in
                self.handleResult(chatMessage, state: .Fail)
        })
    }
    
    // MARK: - Helper functions
    
    private func handleResult(chatMessage: ChatMessage, state: ChatMessageSendState) {
        updateMessageSendState(chatMessage, state: state)
        if chatMessage.photo.id == photoId {
            handleSendChatMessageResult(chatMessage, chatMessageSendState: state)
        }
    }
    
    // MARK: - Realm operations
    
    private func saveChatMessage(chatMessage: ChatMessage) {
        SwishDatabase.saveChatMessage(photoId, chatMessage: chatMessage)
    }
    
    private func updateMessageSendState(chatMessage: ChatMessage, state: ChatMessageSendState) {
        SwishDatabase.updateChatMessageState(chatMessage, state: state)
    }
}
