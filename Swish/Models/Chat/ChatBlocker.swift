//
//  ChatBlocker.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 27..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class ChatBlocker {
    
    typealias Callback = (isSuccess: Bool) -> Void
    
    final class func updateChatBlockState(photoId: Photo.ID, state: ChatRoomBlockState, callback: Callback) {
        PhotoServer.cancelUpdateBlockChatState()
        PhotoServer.updateBlockChatState(photoId, state: state, onSuccess: { (result) -> () in
            SwishDatabase.updateChatBlocked(photoId, state: state)
            callback(isSuccess: true)
            }, onFail: { (error) -> () in
                callback(isSuccess: false)
        })
    }
}
