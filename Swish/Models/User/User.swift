//
//  User .swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 5..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    typealias ID = String
    
    static let invalidId = ""
    private static let defaultLevel = 1
    private static let defaultUserActivityRecord = UserActivityRecord.createDefault()
    
    // Mark: Attributes
    
    // required
    dynamic var id: ID = invalidId
    dynamic var level = defaultLevel
    dynamic var name = ""
    dynamic var about = ""
    dynamic var profileUrl = ""
    let photos = List<Photo>()
    let trendingPhotos = List<TrendingPhoto>()
    
    dynamic var sentPhotoCount = 0
    dynamic var likedPhotoCount = 0
    dynamic var dislikedPhotoCount = 0
    
    var userActivityRecord: UserActivityRecord {
        get {
            return UserActivityRecord(sentPhotoCount: sentPhotoCount, likedPhotoCount: likedPhotoCount
                , dislikedPhotoCount: dislikedPhotoCount)
        }
        set {
            sentPhotoCount = newValue.sentPhotoCount
            likedPhotoCount = newValue.likedPhotoCount
            dislikedPhotoCount = newValue.dislikedPhotoCount
        }
    }
    
    // Mark: init
    
    // TODO: convert to protected when becames possible
    convenience init(id: User.ID) {
        self.init()
        self.id = id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

func == (left: User, right: User) -> Bool {
    return left.id == right.id
}
