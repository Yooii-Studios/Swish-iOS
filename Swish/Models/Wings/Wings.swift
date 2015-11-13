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

private let InvalidTimestamp = NSTimeInterval.NaN

final class Wings: Object {
    
    dynamic var capacityAdditive = 0
    dynamic var lastPenaltyCount = 0
    dynamic var lastWingCount = DefaultWingsCapacity
    var lastTimestamp: NSTimeInterval? {
        get {
            return !_lastTimestamp.isNaN ? _lastTimestamp : nil
        }
        set {
            _lastTimestamp = newValue != nil ? newValue! : InvalidTimestamp
        }
    }
    var capacity: Int {
        return DefaultWingsCapacity + capacityAdditive
    }
    var isFullyCharged: Bool {
        return _lastTimestamp.isNaN
    }
    
    private dynamic var _lastTimestamp = InvalidTimestamp
    
    override static func ignoredProperties() -> [String] {
        return ["lastTimestamp"]
    }
}
