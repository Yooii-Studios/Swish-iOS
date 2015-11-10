//
//  WingsWithNoChargeTests.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 9..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Swish

class WingsWithNoChargeTests: BaseWingsTests {
    
    override func setUp() {
        super.setUp()
        do {
            try WingsHelper.use(DefaultWingsCapacity)
        } catch let error {
            XCTFail("Failed to setup: \(error)")
        }
    }
    
    func testAddWings() {
        let wingsToCharge = 3
        
        WingsHelper.increaseWings(wingsToCharge)
        let expectedWings = createEmptyWings(wingsAdditive: wingsToCharge)
        XCTAssertEqual(wings, expectedWings)
    }
    
    func testThrowWingsErrorOnUseWings() {
        assertThrows({ () throws -> Void in
            try WingsHelper.use(1)
            }, type: WingsError.self)
    }
    
    func testChargeToMax() {
        WingsHelper.chargeToMax()
        let expectedWings = createFullChargedWings()
        XCTAssertEqual(wings, expectedWings)
    }
    
    func testIncreaseCapacity() {
        let capacityToIncrease = 3
        
        WingsHelper.increaseCapacity(capacityToIncrease)
        let expectedWings = createFullChargedWings(wingsAdditive: capacityToIncrease, capacityAdditive: capacityToIncrease)
        XCTAssertEqual(wings, expectedWings)
    }
    
    func testApplyPenalty() {
        let penaltyCount = 3
        
        applyPenalty(penaltyCount)
        let expectedWings = createEmptyWings(penaltyCount: penaltyCount)
        XCTAssertEqual(wings, expectedWings)
        
        let timeRequiredForCharge = timeRequiredForChargeWithPenaltyCount(penaltyCount)
        checkTimeLeftToChargeSameAsExpectedTimeLeftToCharge(timeRequiredForCharge)
    }
    
    func testResetPenalty() {
        let penaltyCount = 3
        
        applyPenalty(penaltyCount)
        WingsHelper.resetPenalty()
        
        let timeRequiredForCharge = timeRequiredForChargeWithPenaltyCount(0)
        checkTimeLeftToChargeSameAsExpectedTimeLeftToCharge(timeRequiredForCharge)
    }
    
    func testWaitLess() {
        executeAfterLessThenChargeTime {
            self.checkChargedTimeSameAsExpectedChargedTime(self.TimeShorterThenChargeTime)
        }
    }
    
    func testWaitMore() {
        executeAfterMoreThenChargeTime {
            let expectedWings = self.createEmptyWings(wingsAdditive: 1)
            XCTAssertEqual(self.wings, expectedWings)
            
            let chargedTime = self.TimeLongerThenChargeTime - WingsHelper.DefaultChargingTime
            self.checkChargedTimeSameAsExpectedChargedTime(chargedTime)
        }
    }
    
    func testAddWingsAndWaitLess() {
        let wingsToCharge = 3
        
        WingsHelper.increaseWings(wingsToCharge)
        executeAfterLessThenChargeTime {
            let expectedWings = self.createEmptyWings(wingsAdditive: wingsToCharge)
            XCTAssertEqual(self.wings, expectedWings)
        }
    }
    
    func testAddWingsAndWaitMore() {
        let wingsToCharge = 3
        
        WingsHelper.increaseWings(wingsToCharge)
        executeAfterMoreThenChargeTime {
            let expectedWings = self.createEmptyWings(wingsAdditive: wingsToCharge + 1)
            XCTAssertEqual(self.wings, expectedWings)
        }
    }
    
    private func timeRequiredForChargeWithPenaltyCount(penaltyCount: Int) -> NSTimeInterval {
        return WingsHelper.DefaultChargingTime + WingsHelper.AdditiveChargingTime * Double(penaltyCount)
    }
}
