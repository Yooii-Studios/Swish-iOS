//
//  UserHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 21..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import RealmSwift

final class UserHelper {
    
    final class func renewOtherUser(oldUser: OtherUser, newUser: OtherUser) -> OtherUser {
        if let oldUser = SwishDatabase.otherUser(newUser.id) {
            let photos = List<Photo>()
            photos.appendContentsOf(oldUser.photos)
            photos.appendContentsOf(newUser.photos)
            
            newUser.photos.removeAll()
            newUser.photos.appendContentsOf(photos)
            if newUser.recentlySentPhotoUrls == nil {
                newUser.recentlySentPhotoUrls = oldUser.recentlySentPhotoUrls
            }
        }
        return newUser
    }
}
