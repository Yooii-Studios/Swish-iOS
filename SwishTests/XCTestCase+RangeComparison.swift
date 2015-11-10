//
//  XCTestCase+RangeComparison.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 9..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func assertEqualWithAccuracy(expression1: Int, _ expression2: Int, accuracy: Int) {
        let difference = abs(expression1 - expression2)
        let isInRange = difference <= accuracy
        let message = String(format: "(\"@%@\") is not equal to (\"@%@\") +/- (\"@%@\")",
            arguments: [expression1, expression2, accuracy])
        XCTAssertTrue(isInRange, message)
    }
}
