//
//  ReactKitTests.swift
//   ReactKit의 사용법과 Realm을 사용한 KVO 패턴 동작 확인 및 사용법 기록을 위해 작성
//
//  Swish
//
//  Created by 정동현 on 2015. 11. 11..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest
@testable import Swish

class ReactKitTests: XCTestCase, WingsObservable {
    
    var wingsObserverTag = "ReactKitTests"
    var lastNotifiedWingCount: Int?

    override func setUp() {
        super.setUp()
        cleanUp()
        observeWingsChange()
    }
    
    override func tearDown() {
        stopObservingWingsChange()
        cleanUp()
        super.tearDown()
    }
    
    func testRealmObjectUpdatePropagation() {
        executeAfterDelay(3.0, timeout: 15.0, expectationDescription: "testRealmObjectUpdatePropagation_3") {
            WingsHelper.penalty()
        }
        executeAfterDelay(10.0, timeout: 15.0, expectationDescription: "testRealmObjectUpdatePropagation_10") {
            print("Wings: \(SwishDatabase.wings())")
        }
    }
    
    func wingsCountDidChange(wingCount: Int) {
        if let lastNotifiedWingCount = lastNotifiedWingCount where lastNotifiedWingCount == wingCount {
            XCTFail("wing count \(wingCount) notified more then twice!")
        }
        print("ReactKitTests.wingCount: \(wingCount)")
        lastNotifiedWingCount = wingCount
    }
    
    func wingsTimeLeftToChargeChange(timeLeftToCharge: Int?) {
        print("ReactKitTests.timeLeftToCharge: \(timeLeftToCharge)")
    }
    
    private func cleanUp() {
        WingsHelper.resetDebug()
        lastNotifiedWingCount = nil
    }
}
