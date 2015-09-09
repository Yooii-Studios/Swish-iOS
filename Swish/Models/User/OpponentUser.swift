//
//  OpponentUser.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 4..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation
import RealmSwift

final class OpponentUser: User {
    private static let invalidFetchedTime = NSTimeInterval.NaN
    
    // Mark: Attributes
    let recentlySentPhotoUrls = List<PhotoMetadata>()
    // required
    dynamic var fetchedTimeIntervalSince1970 = invalidFetchedTime
    
//    convenience required init(id: String, builder: (OpponentUser) -> ()) {
//        self.init(id: id, builder: builder as! (User) -> ())
//        builder(self)
//    }
    
    private convenience init(id: String, fetchedTimeIntervalSince1970: NSTimeInterval) {
//        super.init(id: id)
        self.init()
        self.id = id
        self.fetchedTimeIntervalSince1970 = fetchedTimeIntervalSince1970
    }
}

final class PhotoMetadata: Object {
    dynamic var url = ""
}


final class OpponentUserBuilder {
    class func create(id: User.ID, fetchedTimeIntervalSince1970: NSTimeInterval = NSDate().timeIntervalSince1970,
            builder: (OpponentUser) -> ()) -> OpponentUser {
        let me = OpponentUser(id: id, fetchedTimeIntervalSince1970: fetchedTimeIntervalSince1970)
        builder(me)
        return me
    }
}
