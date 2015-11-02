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
    
    // MARK: - Attributes
    
    var recentlySentPhotoUrls: List<PhotoMetadata>? {
        get {
            return hasRecentlySentPhotoUrls ? _recentlySentPhotoUrls : nil
        }
        set {
            if let newValue = newValue {
                _recentlySentPhotoUrls.removeAll()
                _recentlySentPhotoUrls.appendContentsOf(newValue)
                hasRecentlySentPhotoUrls = true
            } else {
                hasRecentlySentPhotoUrls = false
            }
        }
    }
    dynamic var fetchedTimeIntervalSince1970 = invalidFetchedTime
    
    // MARK: Init
    
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
    
    // MARK: - Realm support
    
    private let _recentlySentPhotoUrls = List<PhotoMetadata>()
    private dynamic var hasRecentlySentPhotoUrls = false
}

final class PhotoMetadata: Object {
    dynamic var url = ""
    
    convenience init(url: String) {
        self.init()
        self.url = url
    }
}
