//
//  UserActivityRecord.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 5..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation

struct UserActivityRecord {
    
    let sentPhotoCount: Int
    let likedPhotoCount: Int
    let dislikedPhotoCount: Int
    
    init(sentPhotoCount: Int, likedPhotoCount: Int, dislikedPhotoCount: Int) {
        self.sentPhotoCount = sentPhotoCount
        self.likedPhotoCount = likedPhotoCount
        self.dislikedPhotoCount = dislikedPhotoCount
    }
    
    static func createDefault() -> UserActivityRecord {
        return UserActivityRecord(sentPhotoCount: 0, likedPhotoCount: 0, dislikedPhotoCount: 0)
    }
}
