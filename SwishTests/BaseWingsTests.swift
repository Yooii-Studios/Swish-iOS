//
//  BaseWingsTests.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 5..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest
@testable import Swish
import RealmSwift

class BaseWingsTests: XCTestCase {
    
    typealias AsyncExecutionCompletion = () -> Void
    
    let TimeShorterThenChargeTime = WingsHelper.TimeRequiredForCharge - 1
    let TimeLongerThenChargeTime = WingsHelper.TimeRequiredForCharge + 1
    
    enum WingsChargeType {
        case Full
        case Empty
    }
    
    var wings: Wings!

    override func setUp() {
        super.setUp()
        WingsHelper.resetDebug()
        wings = SwishDatabase.wings()
    }
    
    func createWingsWithChargeType(chargeType: WingsChargeType, wingsAdditive: Int = 0,
        capacityAdditive: Int = 0, penaltyCount: Int = 0) -> Wings {
            let wings = Wings()
            
            if chargeType == .Empty {
                wings.lastWingCount = 0
            }
            
            wings.lastWingCount += wingsAdditive
            wings.capacityAdditive = capacityAdditive
            wings.lastPenaltyCount = penaltyCount
            
            return wings
    }
    
    func applyPenalty(penaltyCount: Int) {
        for _ in 1...penaltyCount {
            WingsHelper.penalty()
        }
    }
    
    func checkTimeLeftToChargeSameAsExpectedTimeLeftToCharge(expectedTimeForCharge: NSTimeInterval) {
        let actualTimeForChargeWithPenalty = WingsHelper.timeLeftToCharge
        XCTAssertEqual(Int(actualTimeForChargeWithPenalty), Int(expectedTimeForCharge))
    }
    
    func checkChargedTimeSameAsExpectedChargedTime(expectedChargedTimeInSec: Double) {
        if let chargedTime = WingsHelper.chargedTime {
            XCTAssertEqualWithAccuracy(chargedTime, expectedChargedTimeInSec, accuracy: 1)
        } else {
            XCTAssertEqual(expectedChargedTimeInSec, 0)
        }
    }
    
    func executeAfterLessThenChargeTime(completion: AsyncExecutionCompletion) {
        executeAfter(TimeShorterThenChargeTime, expectationDescription: "Wait less then charge time",
            completion: completion)
    }
    
    func executeAfterMoreThenChargeTime(completion: AsyncExecutionCompletion) {
        executeAfter(TimeLongerThenChargeTime, expectationDescription: "Wait more then charge time",
            completion: completion)
    }
    
    func createFullChargedWings(wingsAdditive wingsAdditive: Int = 0, capacityAdditive: Int = 0,
        penaltyCount: Int = 0) -> Wings {
            return createWingsWithChargeType(.Full, wingsAdditive: wingsAdditive, capacityAdditive: capacityAdditive,
                penaltyCount: penaltyCount)
    }
    
    func createEmptyWings(wingsAdditive wingsAdditive: Int = 0, capacityAdditive: Int = 0,
        penaltyCount: Int = 0) -> Wings {
            return createWingsWithChargeType(.Empty, wingsAdditive: wingsAdditive, capacityAdditive: capacityAdditive,
                penaltyCount: penaltyCount)
    }
    
    private func executeAfter(timeInSec: Double, expectationDescription: String, completion: AsyncExecutionCompletion) {
        let expectation = expectationWithDescription(expectationDescription)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(timeInSec) * NSEC_PER_SEC)),
            dispatch_get_main_queue()) { () -> Void in
                completion()
                expectation.fulfill()
        }
        waitForExpectationsWithTimeout(TimeLongerThenChargeTime + 3) { error in
            if let error = error {
                XCTFail(error.description)
            }
        }
    }
}

extension Wings: Equatable { }

// 프로덕트 코드에서는 Wings 클래스를 비교해야 하는 경우가 없으므로 테스트 타겟 내에서만 비교 가능하도록 하기 위해 여기에 구현
func ==(lhs: Wings, rhs: Wings) -> Bool {
    // 최신 날개 정보(날개 갯수, 패널티 갯수)는 WingsHelper클래스에서 제공하므로 wings.lastWingCount를 호출하는 것만으로는
    // 최신 정보를 알 수 없기에 수동으로 refresh()를 호출
    WingsHelper.refresh()
    return lhs.capacityAdditive == rhs.capacityAdditive && lhs.lastPenaltyCount == rhs.lastPenaltyCount
        && lhs.lastWingCount == rhs.lastWingCount
}
