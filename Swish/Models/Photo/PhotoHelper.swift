//
//  PhotoHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import RealmSwift

final class PhotoHelper {
    
    static let InvalidPhotoIndex = -1
    
    final class func findIndexOfPhotoWithPhotoId(photoId: Photo.ID, inPhotos photos: [Photo]) -> Int {
        return photos.indexOf { $0.id == photoId } ?? InvalidPhotoIndex
    }
    
    // TODO: Realm에서 지원하게 된다면 senderWithRealmObject를 사용하는 메서드들을 하나로 묶을 수 있는 가능성 있음
    final class func senderWithPhoto(photo: Photo) -> User {
        return senderWithRealmObject(photo, forProperty: "photos")
    }
    
    final class func senderWithTrendingPhoto(trendingPhoto: TrendingPhoto) -> User {
        return senderWithRealmObject(trendingPhoto, forProperty: "trendingPhotos")
    }
    
    private class func senderWithRealmObject(object: Object, forProperty: String) -> User {
        let userCandidate: User
        let meCandidates = object.linkingObjects(Me.self, forProperty: forProperty)
        if meCandidates.count > 0 {
            userCandidate = meCandidates[0]
        } else {
            let otherCandidates = object.linkingObjects(OtherUser.self, forProperty: forProperty)
            userCandidate = otherCandidates[0]
        }
        return userCandidate
    }
}
