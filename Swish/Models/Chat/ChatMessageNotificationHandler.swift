//
//  ChatMessageNotificationHandler.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 21..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftyJSON

final class ChatMessageNotificationHandler {
    
    final func handleUserInfo(notificationInfo: NotificationInfo) {
        let chatMessageJSON = JSON(notificationInfo)["message"]
        let photoId = parsePhotoIdFromUserInfo(chatMessageJSON)
        let chatMessage = parseChatMessageFromUserInfo(chatMessageJSON)
        
        SwishDatabase.saveChatMessage(photoId, chatMessage: chatMessage)
        // TODO: 해당 photoId의 채팅방 화면이 최상위에 있다면 notify(local notification), 읽지 않은 메시지 갯수는 무조건 올려주기
        SwishDatabase.increaseUnreadChatCount(photoId)
        // TODO: 채팅방 화면에서는 채팅을 받을 때마다 아래를 호출(이 파일에는 없어야 함)
        // SwishDatabase.updateAllChatRead(<#T##id: ID##ID#>)
    }
    
    // MARK: - Parsers
    // TODO: apns가 셋업 되면 실제 파싱으로 변경
    
    private func parsePhotoIdFromUserInfo(chatMessageJSON: JSON) -> Photo.ID {
        return chatMessageJSON["photo"]["id"].int64Value
    }
    
    private func parseChatMessageFromUserInfo(chatMessageJSON: JSON) -> ChatMessage {
        return ChatMessage.create(chatMessageJSON["content"].stringValue,
            senderId: chatMessageJSON["sender"]["id"].stringValue)
    }
}
