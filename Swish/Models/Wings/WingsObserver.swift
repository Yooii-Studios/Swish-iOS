//
//  WingsObserver.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 11..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit
import SwiftTask

final class WingsObserver {
    
    private let WingCountTagPrefix = "ObserveWingCount_"
    private let TimestampTagPrefix = "ObserveTimestamp_"
    
    // MARK: - Attributes
    
    private var timer: NSTimer?
    private let wings = SwishDatabase.wings()
    
    // KVO Streams
    private var wingsMessageStream: Stream<AnyObject?> {
        if _wingsMessageStream == nil {
            _wingsMessageStream = KVO.startingStream(wings, "lastWingCount").ownedBy(wings)
        }
        return _wingsMessageStream
    }
    private var lastTimestampMessageStream: Stream<AnyObject?> {
        if _lastTimestampMessageStream == nil {
            _lastTimestampMessageStream = KVO.startingStream(wings, "_lastTimestamp").ownedBy(wings)
        }
        return _lastTimestampMessageStream
    }
    private var _wingsMessageStream: Stream<AnyObject?>!
    private var _lastTimestampMessageStream: Stream<AnyObject?>!
    
    private var cancellers = Dictionary<String, Canceller>()
    
    // MARK: - Singleton
    
    private struct Instance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: WingsObserver?
    }
    
    static var instance: WingsObserver {
        get {
            dispatch_once(&Instance.dispatchToken) {
                Instance.instance = WingsObserver()
            }
            return Instance.instance!
        }
    }
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Observe
    
    final func observeWingCountWithTag(tag rawTag: String, handler: (wingCount: Int) -> Void) {
        let wingTag = wingCountTagWithRawTag(rawTag)
        
        let canceller = (wingsMessageStream ~> { wingCount in
            let wingCount = wingCount as! Int
            handler(wingCount: wingCount)
            
            self.toggleTimerRunState()
        })
        registerCanceller(canceller, ofTag: wingTag)
    }
    
    final func observeTimeLeftToChargeWithTag(tag rawTag: String, handler: (timeLeftToCharge: Int?) -> Void) {
        let timestampTag = timestampTagWithRawTag(rawTag)
        
        let canceller = (lastTimestampMessageStream ~> { lastWingCountTimestamp in
            guard let lastWingCountTimestamp = (lastWingCountTimestamp as? Double)
                where !lastWingCountTimestamp.isNaN else {
                    handler(timeLeftToCharge: nil)
                    return
            }
            let timePastSinceLastTimestamp = Int(CFAbsoluteTimeGetCurrent()) - Int(lastWingCountTimestamp)
            let timeLeftToCharge = Int(WingsHelper.chargingTime) - timePastSinceLastTimestamp
            handler(timeLeftToCharge: timeLeftToCharge)
            
            self.toggleTimerRunState()
        })
        registerCanceller(canceller, ofTag: timestampTag)
    }
    
    private func registerCanceller(canceller: Canceller?, ofTag tag: String) {
        cancelWithTag(tag)
        cancellers[tag] = canceller
    }
    
    // MARK: - Cancel
    
    final func cancelObserveWingCountWithTag(tag rawTag: String) {
        cancelWithTag(wingCountTagWithRawTag(rawTag))
    }
    
    final func cancelObserveTimeLeftToChargeWithTag(tag rawTag: String) {
        cancelWithTag(timestampTagWithRawTag(rawTag))
    }
    
    private func cancelWithTag(tag: String) {
        if let previousCanceller = cancellers.removeValueForKey(tag) {
            previousCanceller.cancel()
        }
    }
    
    // MARK: - Tags
    
    private func wingCountTagWithRawTag(rawTag: String) -> String {
        return WingCountTagPrefix + rawTag
    }
    
    private func timestampTagWithRawTag(rawTag: String) -> String {
        return TimestampTagPrefix + rawTag
    }
    
    // MARK: Timer
    
    private func toggleTimerRunState() {
        wings.isFullyCharged ? stopTimer() : startTimer()
    }
    
    private func startTimer() {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshWings", userInfo: nil,
                repeats: true)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // NSTimer가 찾을 수 selector로 만들기 위해 @objc로 선언
    @objc private func refreshWings() {
        WingsHelper.refresh()
    }
}
