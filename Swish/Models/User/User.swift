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
    
    static let InvalidId = ""
    private static let DefaultLevel = 1
    private static let DefaultUserActivityRecord = UserActivityRecord.createDefault()
    
    // MARK: - Attributes
    
    dynamic var id: ID = InvalidId
    dynamic var level = DefaultLevel
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
    
    // MARK: - Init
    
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
