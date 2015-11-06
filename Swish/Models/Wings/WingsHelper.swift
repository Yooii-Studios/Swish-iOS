//
//  WingsHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 5..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class WingsHelper {
    
    private static let TimeRequiredForCharge: NSTimeInterval = 30
    private static let AdditiveTimeForCharge: NSTimeInterval = TimeRequiredForCharge
    
    final class func getChargeTimeIncludingPenalty() -> NSTimeInterval {
        return TimeRequiredForCharge + AdditiveTimeForCharge * Double(SwishDatabase.wings().lastPenaltyCount)
    }
    
    // MARK: - Add Wings
    
    private class func addWingAndNotify(additive: Int) {
        let wings = SwishDatabase.wings()
        let prevWingCount = wings.lastWingCount
        addWingAllowingOverCharge(additive)
        
        saveTimestampWithPreviousWingCount(prevWingCount, currentWingCount: wings.lastWingCount)
        // TODO: notifyWingCountChange()
    }
    
    private class func addWingAllowingOverCharge(additive: Int) {
        addWing(additive, allowingOverCharge: true)
    }
    
    private class func addWing(additive: Int) {
        addWing(additive, allowingOverCharge: false)
    }
    
    private class func addWing(additive: Int, allowingOverCharge allowOverCharge: Bool) {
        let wings = SwishDatabase.wings()
        let targetWingCount = wings.lastWingCount + additive
        let actualWingCount = max(allowOverCharge ? targetWingCount : min(wings.capacity, targetWingCount), 0)
        SwishDatabase.updateLastWingsCount(actualWingCount)
    }
    
    // MARK: - Penalty
    
    // TODO: 인터널 메서드 명명을 언더스코어로 시작하려고 했는데 우성이형과 논의해본 결과 명확한 이름으로 정하자고 결정됨
    private class func addPenalty(count: Int) {
        refreshCount()
        applyPenalty(count)
    }
    
    private class func applyPenalty(count: Int) {
        if count > 0 {
            let wings = SwishDatabase.wings()
            let lastWingCount = wings.lastWingCount
            let wingsToConsume = min(lastWingCount, count)
            addWingAndNotify(-wingsToConsume)
            
            let penaltyAdditive = count - lastWingCount
            
            if penaltyAdditive > 0 {
                addPenalty(penaltyAdditive)
            }
        } else {
            addPenalty(count)
        }
    }
    
    private class func addAndSavePenaltyAndNotify(additive: Int) {
        let totalAdditive = SwishDatabase.wings().lastPenaltyCount + additive
        SwishDatabase.updateWingsPenalty(totalAdditive)
        // TODO: notifyChargeTimeChange()
    }
    
    // MARK: - Capacity
    
    private class func addAndSaveCapacityAndNotify(additive: Int) {
        let totalAdditive = SwishDatabase.wings().capacityAdditive + additive
        SwishDatabase.updateWingsCapacityAdditive(totalAdditive)
        // TODO: notifyCapacityChange()
    }
    
    // MARK: - Refresh internal state
    
    // 변수들이 여러 계산에 사용되어 메서드로 추출하기가 어려워 불가피하게 아래와 같이 주석으로 의미 구분
    private class func refreshCount() {
        let wings = SwishDatabase.wings()
        guard let lastTimestamp = wings.lastTimestamp else {
            return
        }
        var timeToConsume = CFAbsoluteTimeGetCurrent() - lastTimestamp
        var chargedWingCount = 0
        var newTimestamp = lastTimestamp
        
        // consume penalty
        var remainingPenalty = wings.lastPenaltyCount
        
        let chargeTimeIncludingPenalty = getChargeTimeIncludingPenalty()
        if (remainingPenalty > 0 && timeToConsume > chargeTimeIncludingPenalty) {
            chargedWingCount++
            newTimestamp += chargeTimeIncludingPenalty
            
            // consume
            remainingPenalty = 0
            SwishDatabase.updateWingsPenalty(remainingPenalty)
            timeToConsume -= chargeTimeIncludingPenalty
        }
        
        // consume normally
        if (remainingPenalty == 0 && timeToConsume > TimeRequiredForCharge) {
            chargedWingCount += Int(timeToConsume / TimeRequiredForCharge)
            newTimestamp += Double(chargedWingCount) * TimeRequiredForCharge
        }
        let previousWingCount = wings.lastWingCount
        addWing(chargedWingCount)
        saveTimestampWithPreviousWingCount(previousWingCount, currentWingCount: wings.lastWingCount, timestamp: newTimestamp)
    }
    
    //  날개 갯수 변경에 따른 timestamp 변화
    //
    // No   Previous    Current     Action
    // 1.   Full        Full        Reset timestamp
    // 2.   Full        Not Full    Save now as timestamp
    // 3.   Not Full    Full        Reset timestamp
    // 4.   Not Full    Not Full    Calculated timestamp
    private class func saveTimestampWithPreviousWingCount(previousWingCount: Int, currentWingCount: Int,
        var timestamp: NSTimeInterval? = nil) {
            let wings = SwishDatabase.wings()
            if currentWingCount >= wings.capacity {
                SwishDatabase.resetLastWingCountChangedTimestamp()
            } else {
                if previousWingCount >= wings.capacity {
                    timestamp = CFAbsoluteTimeGetCurrent()
                }
                if let timestamp = timestamp {
                    SwishDatabase.updateLastWingCountChangedTimestamp(timestamp)
                }
            }
    }
}
