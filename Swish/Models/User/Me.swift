//
//  Me.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 5..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation

final class Me: User {
    // Mark: Attributes
    // required
    dynamic var token = ""
    dynamic var totalExpForNextLevel = 1
    dynamic var currentExp = 0
    
    private convenience init(id: String, token: String) {
        //        super.init(id: id)
        self.init()
        self.id = id
        self.token = token
    }
}

final class MeBuilder {
    final class func create(userId: User.ID, token: String, builder: (Me) -> ()) -> Me {
        let me = Me(id: userId, token: token)
        builder(me)
        return me
    }
}
