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
            let photos = gatherPhotos(oldUser, newUser: newUser)
            newUser.photos.removeAll()
            newUser.photos.appendContentsOf(photos)
            
            let trendingPhotos = gatherTrendingPhotos(oldUser, newUser: newUser)
            newUser.trendingPhotos.removeAll()
            newUser.trendingPhotos.appendContentsOf(trendingPhotos)
            
            if newUser.recentlySentPhotoUrls == nil {
                newUser.recentlySentPhotoUrls = oldUser.recentlySentPhotoUrls
            }
        }
        return newUser
    }
    
    final class func gatherPhotos(oldUser: OtherUser, newUser: OtherUser) -> List<Photo> {
        let photos = List<Photo>()
        photos.appendContentsOf(oldUser.photos)
        photos.appendContentsOf(newUser.photos)
        return photos
    }
    
    final class func gatherTrendingPhotos(oldUser: OtherUser, newUser: OtherUser) -> List<TrendingPhoto> {
        let trendingPhotos = List<TrendingPhoto>()
        trendingPhotos.appendContentsOf(oldUser.trendingPhotos)
        trendingPhotos.appendContentsOf(newUser.trendingPhotos)
        return trendingPhotos
    }
}
