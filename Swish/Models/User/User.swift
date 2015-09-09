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
    
    private static let invalidId = ""
    private static let defaultLevel = 1
    private static let defaultUserActivityRecord = UserActivityRecord.createDefault()
    
    // Mark: Attributes
    // required
    dynamic var id:ID = invalidId
    dynamic var level = defaultLevel
    dynamic var name = ""
    dynamic var about = ""
    dynamic var profileUrl = ""
    let photos = List<Photo>()
    
    dynamic var sentPhotoCount = 0
    dynamic var likedPhotoCount = 0
    dynamic var dislikedPhotoCount = 0
    
    var userActivityRecord:UserActivityRecord {
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
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
//    required init() {
//        super.init()
//    }
//    
//    required init(realm: RLMRealm, schema: RLMObjectSchema) {
//        super.init(realm: realm, schema: schema)
//    }
    
    
//    // Mark: Realm support
//    dynamic var sentPhotoCount: Int {
//        return userActivityRecord.sentPhotoCount
//    }
//    dynamic var likedPhotoCount: Int {
//        return userActivityRecord.likedPhotoCount
//    }
//    dynamic var dislikedPhotoCount: Int {
//        return userActivityRecord.dislikedPhotoCount
//    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

func == (left: User, right: User) -> Bool {
    return left.id == right.id
}
