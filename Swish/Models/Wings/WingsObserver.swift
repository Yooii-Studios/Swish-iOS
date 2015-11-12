//
//  WingsObserver.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 11..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import ReactKit

final class WingsObserver {
    
    // MARK: - Attributes
    
    private var timer: NSTimer?
    private let wings = SwishDatabase.wings()
    
    // KVO Streams
    private var wingsMessageStream: Stream<AnyObject?> {
        if _wingsMessageStream == nil {
            _wingsMessageStream = KVO.stream(wings, "lastWingCount").ownedBy(wings)
        }
        return _wingsMessageStream
    }
    private var lastTimestampMessageStream: Stream<AnyObject?> {
        if _lastTimestampMessageStream == nil {
            _lastTimestampMessageStream = KVO.stream(wings, "_lastTimestamp").ownedBy(wings)
        }
        return _lastTimestampMessageStream
    }
    private var _wingsMessageStream: Stream<AnyObject?>!
    private var _lastTimestampMessageStream: Stream<AnyObject?>!
    
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
    
    final func observeWingCount(handler: (wingCount: Int) -> Void) {
        wingsMessageStream ~> {
            handler(wingCount: $0 as! Int)
        }
        startTimer()
    }
    
    final func observeTimeLeftToCharge(handler: (timeLeftToCharge: Int) -> Void) {
        lastTimestampMessageStream ~> { lastWingCountTimestamp in
            let timePastSinceLastTimestamp = Int(CFAbsoluteTimeGetCurrent()) - (lastWingCountTimestamp as! Int)
            let timeLeftToCharge = Int(WingsHelper.chargingTime) - timePastSinceLastTimestamp
            handler(timeLeftToCharge: timeLeftToCharge)
        }
        startTimer()
    }
    
    private func startTimer() {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil,
                repeats: true)
        }
    }
    
    // NSTimer가 찾을 수 selector로 만들기 위해 @objc로 선언
    @objc private func tick() {
        WingsHelper.refresh()
    }
}
