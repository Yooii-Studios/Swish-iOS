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
import ReactKit
@testable import Swish

class ReactKitTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        SwishDatabase.deleteAll()
    }
    
    override func tearDown() {
        SwishDatabase.deleteAll()
        super.tearDown()
    }
    
    func testRealmObjectUpdatePropagation() {
        WingsObserver.instance.observeWingCount {
            print("wingsMessageStream: \($0)")
        }
        WingsObserver.instance.observeTimeLeftToCharge {
            print("timeLeftToChargeStream: \($0)")
        }
        
        try! WingsHelper.use(10)
        
        executeAfterDelay(3.0, timeout: 15.0, expectationDescription: "testRealmObjectUpdatePropagation_3") {
            WingsHelper.penalty()
        }
        executeAfterDelay(10.0, timeout: 15.0, expectationDescription: "testRealmObjectUpdatePropagation_10") {
            print("Wings: \(SwishDatabase.wings())")
        }
    }
}
