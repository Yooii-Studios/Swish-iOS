//
//  ChatMessageNotificationHandler.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 21..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class ChatMessageNotificationHandler {
    
    final func handleUserInfo(notificationInfo: NotificationInfo) {
        let photoId = parsePhotoIdFromUserInfo(notificationInfo)
        let chatMessage = parseChatMessageFromUserInfo(notificationInfo)
        SwishDatabase.saveChatMessage(photoId, chatMessage: chatMessage)
        
        // TODO: 해당 photoId의 채팅방 화면이 최상위에 있다면 notify(local notification), 읽지 않은 메시지 갯수는 무조건 올려주기
//        SwishDatabase.increaseUnreadChatCount(<#T##id: ID##ID#>)
        // TODO: 채팅방 화면에서는 채팅을 받을 때마다 아래를 호출(이 파일에는 없어야 함)
//        SwishDatabase.updateAllChatRead(<#T##id: ID##ID#>)
    }
    
    // MARK: - Parsers
    // TODO: apns가 셋업 되면 실제 파싱으로 변경
    
    private func parsePhotoIdFromUserInfo(notificationInfo: NotificationInfo) -> Photo.ID {
        return -1
    }
    
    private func parseChatMessageFromUserInfo(notificationInfo: NotificationInfo) -> ChatMessage {
        return ChatMessage.create("dummy message", senderId: "-1")
    }
}
