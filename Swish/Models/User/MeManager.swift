//
//  MeUtils.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 12..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

final class MeManager {
    
    typealias DefaultCallback = () -> ()
    
    class func me() -> Me {
        return SwishDatabase.me()
    }
    
    class func registerMe(name: String? = nil, about: String? = nil, image: UIImage? = nil,
        onSuccess: ((me: Me) -> ())? = nil, onFail: DefaultCallback? = nil) {
            UserServer.registerMe(name, about: about, image: image,
                onSuccess: { (me) -> () in
                    SwishDatabase.saveMe(me)
                    onSuccess?(me: me)
                }, onFail: { (error) -> () in
                    onFail?()
            })
    }
    
    class func updateMe(name: String? = nil, about: String? = nil,
        onSuccess: DefaultCallback? = nil, onFail: DefaultCallback? = nil) {
            let userId = SwishDatabase.me().id
            UserServer.updateMe(userId, name: name, about: about,
                onSuccess: { (result) -> () in
                    SwishDatabase.updateMe(name, about: about)
                    onSuccess?()
                }, onFail: { (error) -> () in
                    onFail?()
            })
    }
    
    class func updateMyDeviceToken(deviceToken: String,
        onSuccess: DefaultCallback? = nil, onFail: DefaultCallback? = nil) {
            let userId = SwishDatabase.me().id
            UserServer.updateMyDeviceToken(
                userId,
                deviceToken: deviceToken,
                onSuccess: { _ in onSuccess?() },
                onFail: { _ in onFail?() }
            )
    }
    
    class func updateMyProfileImage(image: UIImage,
        onSuccess: ((profileImageUrl: String) -> ())? = nil, onFail: DefaultCallback? = nil) {
            let userId = SwishDatabase.me().id
            UserServer.updateMyProfileImage(userId, image: image,
                onSuccess: { (profileImageUrl) -> () in
                    SwishDatabase.updateMyProfileImage(profileImageUrl)
                    onSuccess?(profileImageUrl: profileImageUrl)
                }, onFail: { (error) -> () in
                    onFail?()
            })
    }
    
    class func updateMyActivityStatus(onSuccess: ((record: UserActivityRecord) -> ())? = nil,
        onFail: DefaultCallback? = nil) {
            let userId = SwishDatabase.me().id
            UserServer.activityRecordWith(userId,
                onSuccess: { (record) -> () in
                    SwishDatabase.updateMyActivityRecord(record)
                    onSuccess?(record: record)
                }, onFail: { (error) -> () in
                    onFail?()
            })
    }
    
    class func fetchMyUnreadChatMessages() {
        let userId = SwishDatabase.me().id
        UserServer.getUnreadChatMessages(
            userId,
            onSuccess: { photoIdAndChatMessages in
                saveChatMessages(photoIdAndChatMessages)
                UserServer.makeChatMessagesRead(
                    userId,
                    readChatMessages: photoIdAndChatMessages.map{ $0.chatMessage },
                    onSuccess: { _ in},
                    onFail: { print($0) }
                )
            },
            onFail: { print($0) }
        )
    }
    
    class func saveMyLevelInfo(userLevelInfo: UserLevelInfo) {
        SwishDatabase.updateMyLevelInfo(userLevelInfo)
    }
    
    private class func saveChatMessages(photoIdAndChatMessages: [PhotoIDAndChatMessage]) {
        for photoIdAndChatMessage in photoIdAndChatMessages {
            SwishDatabase.saveChatMessage(photoIdAndChatMessage.photoId,
                chatMessage: photoIdAndChatMessage.chatMessage)
            SwishDatabase.increaseUnreadChatCount(photoIdAndChatMessage.photoId)
        }
    }
}
