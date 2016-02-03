//
//  RateNotificationHandler.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 21..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftyJSON

final class RateNotificationHandler {
    
    final func handleNotificationInfo(notificationInfo: NotificationInfo) {
        let userLevelJSON = JSON(notificationInfo)["current_level_info"]
        let photoJSON = JSON(notificationInfo)["photo"]
        saveUserLevelInfo(userLevelJSON)
        handleReceivedLikeOrDislike(photoJSON)
        showLevelChangePopupIfNecessary()
    }
    
    private final func saveUserLevelInfo(userLevelJSON: JSON) {
        MeManager.saveMyLevelInfo(parseUserLevelInfoFromUserInfo(userLevelJSON))
    }
    
    private final func handleReceivedLikeOrDislike(photoJSON: JSON) {
        let rate = parseRateFromUserInfo(photoJSON)
        
        updatePhotoWithRate(rate)
        updateWingsWithRate(rate)
        
        // TODO: like / dislike 판단해 notify
    }
    
    private final func showLevelChangePopupIfNecessary() {
        // TODO: 필요한 경우 레벨업 화면 표시
    }
    
    private final func updatePhotoWithRate(rate: Rate) {
        SwishDatabase.updatePhoto(rate.photoId) { photo in
            photo.photoState = rate.isLiked ? .Liked : .Disliked
            photo.arrivedLocation = rate.arrivedLocation
            
            if rate.isLiked {
                photo.receivedUserId = (rate as! Like).likedUserId
            }
        }
    }
    
    private final func updateWingsWithRate(rate: Rate) {
        if SwishDatabase.photoWithId(rate.photoId) != nil {
            // 안드로이드와 마찬가지로 사진이 있는 경우에만 날개 업데이트
            if rate.isLiked {
                WingsHelper.increaseWings(1, allowingOverCharge: false)
            } else {
                WingsHelper.useIgnoringException()
                WingsHelper.useIgnoringException()
            }
        }
    }
    
    // MARK: - Parsers
    // TODO: apns가 셋업 되면 실제 파싱으로 변경
    
    private func parseUserLevelInfoFromUserInfo(userLevelJSON: JSON) -> UserLevelInfo {
        return UserLevelInfo(level: userLevelJSON["level"].intValue,
            totalExpToNextLevel: userLevelJSON["total_exp_for_next"].intValue,
            currentExp: userLevelJSON["current_exp"].intValue)
    }
    
    private func parseRateFromUserInfo(photoJSON: JSON) -> Rate {
        let photoId: Photo.ID = photoJSON["id"].int64Value
        let deliveredLatLng = CLLocation(latitude: photoJSON["delivered_location"]["latitude"].doubleValue,
            longitude: photoJSON["delivered_location"]["longitude"].doubleValue)
        let likedUserId = photoJSON["user_info"]["id"].stringValue
        
        return photoJSON["state"].intValue == PhotoState.Liked.key ?
            Like(photoId: photoId, deliveredLatLng: deliveredLatLng, likedUserId: likedUserId)
            : Dislike(photoId: photoId, deliveredLatLng: deliveredLatLng)
    }
}

private class Rate {
    let photoState: PhotoState
    let photoId: Photo.ID
    let arrivedLocation: CLLocation
    var isLiked: Bool {
        return self is Like
    }
    
    init(photoState: PhotoState, photoId: Photo.ID, deliveredLatLng: CLLocation) {
        self.photoState = photoState
        self.photoId = photoId
        self.arrivedLocation = deliveredLatLng
    }
}

private final class Like: Rate {
    
    let likedUserId: User.ID
    
    init(photoId: Photo.ID, deliveredLatLng: CLLocation, likedUserId: User.ID) {
        self.likedUserId = likedUserId
        super.init(photoState: .Liked, photoId: photoId, deliveredLatLng: deliveredLatLng)
    }
}

private final class Dislike: Rate {
    
    init(photoId: Photo.ID, deliveredLatLng: CLLocation) {
        super.init(photoState: .Disliked, photoId: photoId, deliveredLatLng: deliveredLatLng)
    }
}
