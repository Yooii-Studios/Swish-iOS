//
//  WingsHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 5..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class WingsHelper {
    
    static let DefaultChargingTime: NSTimeInterval = EnvironmentVariables.IsTesting ? 5 : 30 * 60
    static let AdditiveChargingTime: NSTimeInterval = DefaultChargingTime
    
    // MARK: - Attributes
    
    final class var chargedTime: Double? {
        if let lastWingCountTimestamp = wings().lastTimestamp {
            return CFAbsoluteTimeGetCurrent() - lastWingCountTimestamp
        } else {
            return nil
        }
    }
    
    final class var chargingTime: NSTimeInterval {
        return DefaultChargingTime + AdditiveChargingTime * Double(wings().lastPenaltyCount)
    }
    
    // MARK: - Serivces
    
    final class func refreshWings() {
        refreshInternalState()
    }
    
    final class func addOneWing() {
        increaseWings(1)
    }
    
    final class func increaseWings(count: Int, allowingOverCharge: Bool = true) {
        refreshInternalState()
        applyWingsAdditiveAndNotify(count, allowingOverCharge: allowingOverCharge)
    }
    
    final class func useIgnoringException() {
        let _ = try? use()
    }
    
    final class func use() throws {
        try use(1)
    }
    
    final class func use(var count: Int) throws {
        refreshInternalState()
        count = -abs(count)
        try checkApplyAdditiveWingsCountSuitable(count)
        applyWingsAdditiveAndNotify(count)
    }
    
    final class func chargeToMax() {
        refreshInternalState()
        // 풀 충전할 경우 패널티도 없에도록 구현
        resetPenalty()
        let wings = self.wings()
        applyWingsAdditiveAndNotify(wings.capacity - wings.lastWingCount)
    }
    
    final class func increaseCapacity(additive: Int) {
        refreshInternalState()
        applyCapacityAdditiveAndNotify(additive)
        // 용량 늘릴 경우 풀 충전 해주도록 함
        chargeToMax()
    }
    
    final class func penalty() {
        refreshInternalState()
        applyPenaltyAdditive(1)
    }
    
    final class func resetPenalty() {
        refreshInternalState()
        applyPenaltyAdditive(-wings().lastPenaltyCount)
    }
    
    final class func isFullyCharged() -> Bool {
        refreshInternalState()
        return wings().isFullyCharged
    }
    
    // TODO: Debug 모드에서만 작동하도록 수정
    final class func resetDebug() {
        let previousWings = wings()
        let newWings = Wings()
        
        SwishDatabase.write { () -> Void in
            previousWings.lastWingCount = newWings.lastWingCount
            previousWings.lastPenaltyCount = newWings.lastPenaltyCount
            previousWings.capacityAdditive = newWings.capacityAdditive
            previousWings.lastTimestamp = newWings.lastTimestamp
        }
    }
    
    // MARK: - Add Wings
    
    private class func applyWingsAdditiveAndNotify(additive: Int, allowingOverCharge: Bool = true) {
        let prevWingCount = wings().lastWingCount
        applyWingsAdditive(additive, allowingOverCharge: allowingOverCharge)
        
        saveTimestampWithPreviousWingCount(prevWingCount, currentWingCount: wings().lastWingCount)
    }
    
    private class func applyWingAdditive(additive: Int) {
        applyWingsAdditive(additive, allowingOverCharge: false)
    }
    
    private class func applyWingsAdditive(additive: Int, allowingOverCharge allowOverCharge: Bool) {
        let wings = self.wings()
        let targetWingCount = wings.lastWingCount + additive
        let actualWingCount = max(allowOverCharge ? targetWingCount : min(wings.capacity, targetWingCount), 0)
        SwishDatabase.updateLastWingsCount(actualWingCount)
    }
    
    // MARK: - Penalty
    
    private class func applyPenaltyAdditive(additive: Int) {
        if additive > 0 {
            let lastWingCount = wings().lastWingCount
            let wingsToConsume = min(lastWingCount, additive)
            applyWingsAdditiveAndNotify(-wingsToConsume)
            
            let penaltyAdditive = additive - lastWingCount
            
            if penaltyAdditive > 0 {
                applyPenaltyAdditiveAndNotify(penaltyAdditive)
            }
        } else {
            applyPenaltyAdditiveAndNotify(additive)
        }
    }
    
    private class func applyPenaltyAdditiveAndNotify(additive: Int) {
        let totalAdditive = wings().lastPenaltyCount + additive
        SwishDatabase.updateWingsPenalty(totalAdditive)
    }
    
    // MARK: - Capacity
    
    private class func applyCapacityAdditiveAndNotify(additive: Int) {
        let totalAdditive = wings().capacityAdditive + additive
        SwishDatabase.updateWingsCapacityAdditive(totalAdditive)
    }
    
    // MARK: - Refresh internal state
    
    // 변수들이 여러 계산에 사용되어 메서드로 추출하기가 어려워 불가피하게 아래와 같이 주석으로 의미 구분
    private class func refreshInternalState() {
        let wings = self.wings()
        guard let lastTimestamp = wings.lastTimestamp else {
            return
        }
        var timeToConsume = CFAbsoluteTimeGetCurrent() - lastTimestamp
        var chargedWingCount = 0
        var newTimestamp = lastTimestamp
        
        // consume penalty
        var remainingPenalty = wings.lastPenaltyCount
        
        let chargeTimeIncludingPenalty = chargingTime
        if (remainingPenalty > 0 && timeToConsume > chargeTimeIncludingPenalty) {
            chargedWingCount++
            newTimestamp += chargeTimeIncludingPenalty
            
            // consume
            remainingPenalty = 0
            SwishDatabase.updateWingsPenalty(remainingPenalty)
            timeToConsume -= chargeTimeIncludingPenalty
        }
        
        // consume normally
        if (remainingPenalty == 0 && timeToConsume > DefaultChargingTime) {
            chargedWingCount += Int(timeToConsume / DefaultChargingTime)
            newTimestamp += Double(chargedWingCount) * DefaultChargingTime
        }
        let previousWingCount = wings.lastWingCount
        applyWingAdditive(chargedWingCount)
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
            let wings = self.wings()
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
    
    // MARK: - Check internal state
    
    private class func checkApplyAdditiveWingsCountSuitable(additive: Int) throws {
        let currentWingsCount = wings().lastWingCount
        let targetWingsCount = currentWingsCount + additive
        if targetWingsCount < 0 {
            let queriedWingsCount = abs(additive)
            throw WingsError.InsufficientWings(currentWingsCount: currentWingsCount,
                queriedWingsCount: queriedWingsCount, insufficientWingsCount: queriedWingsCount - currentWingsCount)
        }
    }
    
    // MARK: - Helper functions
    
    private class func wings() -> Wings {
        return SwishDatabase.wings()
    }
}

enum WingsError: ErrorType, CustomStringConvertible {
    
    case InsufficientWings(currentWingsCount: Int, queriedWingsCount: Int, insufficientWingsCount: Int)
    
    var description: String {
        switch(self) {
        case .InsufficientWings(let currentWingsCount, let queriedWingsCount, _):
            return "Queried \(queriedWingsCount) wings but has \(currentWingsCount) wings"
        }
    }
}
