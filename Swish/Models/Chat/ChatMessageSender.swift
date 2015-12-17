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
//    3. PhotoViewCell.swift 파일 참조해서
//       ChatObserver.observeChatMessageStateForChatMessage(바인딩시),
//       ChatObserver.unobserveChatMessageStateWithChatMessage(clear, deinit)
//       적용
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
    
    var photoId: Photo.ID { get }
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
