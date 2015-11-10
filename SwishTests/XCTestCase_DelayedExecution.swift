//
//  XCTestCase_DelayedExecution.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 10..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    typealias AsyncExecutionCompletion = () -> Void
    
    func executeAfterDelay(delay: NSTimeInterval, timeout: NSTimeInterval, expectationDescription: String,
        completion: AsyncExecutionCompletion) {
        let expectation = expectationWithDescription(expectationDescription)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(delay) * NSEC_PER_SEC)),
            dispatch_get_main_queue()) {
                completion()
                expectation.fulfill()
        }
        waitForExpectationsWithTimeout(timeout) { error in
            if let error = error {
                XCTFail(error.description)
            }
        }
    }
}
