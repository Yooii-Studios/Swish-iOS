//
//  OtherUser.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 4..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation
import RealmSwift

final class OtherUser: User {
    private static let invalidFetchedTime = NSTimeInterval.NaN
    
    // Mark: Attributes
    
    let recentlySentPhotoUrls = List<PhotoMetadata>()
    // required
    dynamic var fetchedTimeIntervalSince1970 = invalidFetchedTime
    
    private convenience init(id: String, fetchedTimeIntervalSince1970: NSTimeInterval) {
        self.init()
        self.id = id
        self.fetchedTimeIntervalSince1970 = fetchedTimeIntervalSince1970
    }
    
    final class func create(id: User.ID,
        builder: (OtherUser) -> () = RealmObjectBuilder.builder) -> OtherUser {
            let me = OtherUser(id: id, fetchedTimeIntervalSince1970: NSDate().timeIntervalSince1970)
            builder(me)
            return me
    }
}

final class PhotoMetadata: Object {
    dynamic var url = ""
    
    convenience init(url: String) {
        self.init()
        self.url = url
    }
}
