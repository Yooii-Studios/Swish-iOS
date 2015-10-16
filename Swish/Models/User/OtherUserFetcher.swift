//
//  OtherUserFetcher.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 12..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class OtherUserFetcher {
    typealias DefaultCallback = () -> ()
    
    class func otherUserWithUserId(userId: User.ID, onSuccess: (otherUser: OtherUser) -> (),
        onFail: DefaultCallback) {
            UserServer.otherUserWith(userId,
                onSuccess: { (otherUser) -> () in
                    SwishDatabase.saveOtherUser(otherUser)
                    onSuccess(otherUser: otherUser)
                }, onFail: { (error: SwishError) -> () in
                    onFail()
            })
    }
}
