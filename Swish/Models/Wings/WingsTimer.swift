//
//  WingsTimer.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 11..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class WingsTimer {
    
    typealias OnTick = (chargedWingCount: Int, timeLeftToCharge: Int) -> Void
    
    // MARK: - Attributes
    
    private var chargingTime: Int!
    private var chargedTime: Int?
    private var timer: NSTimer?
    private var onTicks = Dictionary<String, OnTick>()
    
    // MARK: - Singleton
    
    private struct Instance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: WingsTimer?
    }
    
    static var instance: WingsTimer {
        get {
            dispatch_once(&Instance.dispatchToken) {
                Instance.instance = WingsTimer()
            }
            return Instance.instance!
        }
    }
    
    // MARK: - Initializers
    
    private init() { }
    
    final func startWithTag(tag: String, execution: OnTick) {
        chargedTime = WingsHelper.chargedTime != nil ? Int(WingsHelper.chargedTime!) : nil
        guard chargedTime != nil && !WingsHelper.isFullyCharged() else {
            return
        }
        
        chargingTime = Int(WingsHelper.chargingTime)
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil,
                repeats: true)
        }
        onTicks[tag] = execution
    }
    
    final func stopWithTag(tag: String) {
        onTicks.removeValueForKey(tag)
        if onTicks.count == 0 {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // NSTimer가 찾을 수 selector로 만들기 위해 @objc로 선언
    @objc private func tick() {
        guard let timeLeftToCharge = evaluateTimeLeftToCharge() else {
            return
        }
        for (tag, execution) in onTicks {
            print("tag: \(tag)")
            execution(chargedWingCount: WingsHelper.wingCount, timeLeftToCharge: timeLeftToCharge)
        }
    }
    
    private func evaluateTimeLeftToCharge() -> Int? {
        guard progress() else {
            return nil
        }
        return chargingTime - chargedTime!
    }
    
    private func progress() -> Bool {
        guard var chargedTime = ++chargedTime where !WingsHelper.isFullyCharged() else {
            return false
        }
        
        if chargedTime > chargingTime {
            chargedTime %= chargingTime
            self.chargedTime = chargedTime
        }
        return true
    }
}
