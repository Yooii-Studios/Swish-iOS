//
//  PhotoState.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 3..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation

enum PhotoState: String {
    case Waiting = "Waiting"
    case Delivered = "Delivered"
    case Liked = "Liked"
    case Disliked = "Disliked"
    
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
