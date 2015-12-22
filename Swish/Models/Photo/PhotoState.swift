//
//  PhotoState.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 3..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation

enum PhotoState {
    
    case Waiting
    case Delivered
    case Liked
    case Disliked
    
    var key: Int {
        var key: Int
        switch(self) {
        case .Waiting:
            key = 0
        case .Delivered:
            key = 1
        case .Liked:
            key = 2
        case .Disliked:
            key = 3
        }
        
        return key
    }
    
    static func findWithKey(key: Int) -> PhotoState {
        var state: PhotoState
        switch(key) {
        case 0:
            state = .Waiting
        case 1:
            state = .Delivered
        case 2:
            state = .Liked
        case 3:
            state = .Disliked
        default:
            state = .Waiting
        }
        
        return state
    }
}

// Resources
extension PhotoState {
    
    var sentStateResId: String {
        // TODO: 로컬라이징
        switch self {
        case .Waiting:
            return "state_wait"
        case .Delivered:
            return "state_delivered"
        case .Liked:
            return "state_like"
        case .Disliked:
            return "state_dislike"
        }
    }
    var sentStateDescriptionResId: String {
        // TODO: 로컬라이징
        switch self {
        case .Waiting:
            return "state_detail_wait"
        case .Delivered:
            return "state_detail_delivered"
        case .Liked:
            return "state_detail_like"
        case .Disliked:
            return "state_detail_dislike"
        }
    }
    var sentStateImgResId: String {
        switch self {
        case .Waiting:
            return "ic_sent_photo_waiting"
        case .Delivered:
            return "ic_sent_photo_delivered"
        case .Liked:
            return "ic_sent_photo_like"
        case .Disliked:
            return "ic_sent_photo_dislike"
        }
    }
    var sentDetailStateImgResId: String {
        switch self {
        case .Waiting:
            return "ic_photo_detail_waiting"
        case .Delivered:
            return "ic_photo_detail_delivered"
        case .Liked:
            return "ic_photo_detail_like"
        case .Disliked:
            return "ic_photo_detail_dislike"
        }
    }
}
