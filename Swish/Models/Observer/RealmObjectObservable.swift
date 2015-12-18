//
//  RealmObjectObservable.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 17..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit
import SwiftTask

protocol RealmObjectObservable {}

extension RealmObjectObservable {
    
    static func stream(object: NSObject, property: String, owner: NSObject, handler: AnyObject? -> Void) -> Canceller? {
        return KVO.stream(object, property).ownedBy(owner) ~> handler
    }
    
    static func startingStream(object: NSObject, property: String, owner: NSObject, handler: AnyObject? -> Void)
        -> Canceller? {
            return KVO.startingStream(object, property).ownedBy(owner) ~> handler
    }
    
    static func detailedStream(object: NSObject, property: String, owner: NSObject,
        handler: (AnyObject?, NSKeyValueChange, NSIndexSet?) -> Void) -> Canceller? {
            return KVO.detailedStream(object, property).ownedBy(owner) ~> handler
    }
}
