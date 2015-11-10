//
//  Wings.swift
//   날개 정보를 나타냄. 새로고침(최신화)되기 전의 raw data만 저장하므로 최신으로 갱신된 정보는 WingsHelper 클래스에서 가져다 사용해야 한다.
//
//  Swish
//
//  Created by 정동현 on 2015. 11. 5..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import RealmSwift

let DefaultWingsCapacity = 10

final class Wings: Object {
    
    dynamic var capacityAdditive = 0
    dynamic var lastPenaltyCount = 0
    dynamic var lastWingCount = DefaultWingsCapacity
    var lastTimestamp: NSTimeInterval? {
        get {
            return _lastTimestamp.value ?? nil
        }
        set {
            _lastTimestamp.value = newValue
        }
    }
    var capacity: Int {
        return DefaultWingsCapacity + capacityAdditive
    }
    
    private let _lastTimestamp = RealmOptional<NSTimeInterval>()
    
    override static func ignoredProperties() -> [String] {
        return ["lastTimestamp"]
    }
}
