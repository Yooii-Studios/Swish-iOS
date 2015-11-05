//
//  Wings.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 5..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import RealmSwift

final class Wings: Object {
    
    private static let Capacity = 10
    
    dynamic var capacityAdditive = 0
    dynamic var lastPenaltyCount = 0
    dynamic var lastWingCount = Capacity
    var lastTimestamp: NSTimeInterval? {
        get {
            return _lastTimestamp.value ?? nil
        }
        set {
            _lastTimestamp.value = newValue
        }
    }
    
    private let _lastTimestamp = RealmOptional<NSTimeInterval>()
    
    override static func ignoredProperties() -> [String] {
        return ["lastTimestamp"]
    }
}
