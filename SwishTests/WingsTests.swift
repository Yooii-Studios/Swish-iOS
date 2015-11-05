//
//  WingsTests.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 5..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest
@testable import Swish
import RealmSwift

class WingsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SwishDatabase.deleteAll()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let wings = Wings()
        wings.lastWingCount = 7
        wings.lastTimestamp = CFAbsoluteTimeGetCurrent()
        SwishDatabase.write { () -> Void in
            SwishDatabase.realm.add(wings)
        }
        let loadedWings = SwishDatabase.objects(Wings)
        XCTAssertEqual(loadedWings.count, 1)
        XCTAssertEqual(loadedWings[0], wings)
    }

}
