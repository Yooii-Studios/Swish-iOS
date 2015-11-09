//
//  XCTestCase+AssertThrows.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 9..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func assertThrows<T: ErrorType>(block: () throws -> Void, type: T.Type) {
        do {
            try block()
        } catch let error as T {
            if let error = error as? CustomStringConvertible {
                print("Catched expected exception: \(error.description)")
            } else {
                print("Catched expected exception: \(error)")
            }
        } catch {
            XCTFail()
        }
    }
}
