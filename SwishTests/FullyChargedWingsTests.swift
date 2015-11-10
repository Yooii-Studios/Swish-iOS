//
//  FullyChargedWingsTests.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 6..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Swish

class FullyChargedWingsTests: BaseWingsTests {
    
    func testAddWings() {
        let wingsToCharge = 3
        
        WingsHelper.increaseWings(wingsToCharge)
        let expectedWings = createFullChargedWings(wingsAdditive: wingsToCharge)
        XCTAssertEqual(wings, expectedWings)
    }
    
    func testUseWings() {
        let wingsToUse = 3
        
        useWings(wingsToUse)
        let expectedWings = createFullChargedWings(wingsAdditive: -wingsToUse)
        XCTAssertEqual(wings, expectedWings)
    }
    
    func testThrowWingsErrorOnUseWings() {
        assertThrows(WingsError.self) {
            try WingsHelper.use(DefaultWingsCapacity + 3)
        }
    }
    
    func testChargeToMax() {
        WingsHelper.chargeToMax()
        let expectedWings = Wings()
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
        let expectedWings = createFullChargedWings(wingsAdditive: -penaltyCount)
        XCTAssertEqual(wings, expectedWings)
    }
    
    func testResetPenalty() {
        let penaltyCount = 3
        
        applyPenalty(penaltyCount)
        WingsHelper.resetPenalty()
        let expectedWings = createFullChargedWings(wingsAdditive: -penaltyCount)
        XCTAssertEqual(wings, expectedWings)
    }
    
    private func useWings(count: Int) {
        do {
            try WingsHelper.use(count)
        } catch let error as WingsError {
            XCTFail(error.description)
        } catch {
            XCTFail()
        }
    }
}
