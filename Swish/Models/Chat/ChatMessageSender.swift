//
//  ChatMessageSender.swift
//   UIViewController에서 채팅 메시지 전송을 래핑한 Protocol 및 extension
//
//   Usage
//    1. UIViewController 및 sublcass 에 ChatMessageSender 프로토콜 추가
//
//    2. 해당 UIViewController 에 해당하는 사진 id 아래와 같이 제공
//          var photoId: Photo.ID {
//              return photo.id
//          }
//
//    3. func handleSendChatMessageResult(chatMessage: ChatMessage, chatMessageSendState: ChatMessageSendState) 에서
//      ChatMessage 전송 성공 및 실패시의 UI update 구현
//
//
//  Swish
//
//  Created by 정동현 on 2015. 10. 26..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

protocol ChatMessageSender {
    
    // TODO: 우성이 나중에 실제로 사용 해 보고 게터가 있어야 하는지 확인하기
    var photoId: Photo.ID { get }
    
    func handleSendChatMessageResult(chatMessage: ChatMessage, chatMessageSendState: ChatMessageSendState)
}

extension ChatMessageSender where Self: UIViewController {
    
    final func sendChatMessage(chatMessage: ChatMessage) {
        saveChatMessage(chatMessage)
        sendChatMessageToServer(chatMessage)
    }
    
    final func resendChatmessage(chatMessage: ChatMessage) {
        updateMessageSendState(chatMessage, state: .Sending)
        sendChatMessageToServer(chatMessage)
    }
    
    private func sendChatMessageToServer(chatMessage: ChatMessage) {
        PhotoServer.sendChatMessage(chatMessage, onSuccess: { (result) -> () in
            self.handleResult(chatMessage, state: .Success)
            }, onFail: { (error) -> Void in
                self.handleResult(chatMessage, state: .Fail)
        })
    }
    
    // MARK: - Helper functions
    
    private func handleResult(chatMessage: ChatMessage, state: ChatMessageSendState) {
        updateMessageSendState(chatMessage, state: state)
        // TODO: 동현이 안전을 위해서 해당 로직을 넣어놓은 것이고, 추후 사용하면서 필요 없어지면 논의 후 삭제될 수 있음
        if chatMessage.photo.id == photoId {
            handleSendChatMessageResult(chatMessage, chatMessageSendState: state)
        }
    }
    
    // MARK: - Realm operations
    
    private func saveChatMessage(chatMessage: ChatMessage) {
        chatMessage.state = .Sending
        SwishDatabase.saveChatMessage(photoId, chatMessage: chatMessage)
    }
    
    private func updateMessageSendState(chatMessage: ChatMessage, state: ChatMessageSendState) {
        SwishDatabase.updateChatMessageState(chatMessage, state: state)
    }
}
