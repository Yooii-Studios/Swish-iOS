//
//  Timestamp.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 21..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import QuartzCore

final class Timestamp {
    
    private static var pendingEvents = Dictionary<String, NSTimeInterval>()
    
    final class func startAndGetTag() -> String {
        let tag = String(now())
        startWithTag(tag)
        return tag
    }
    
    final class func startWithTag(tag: String) {
        pendingEvents[tag] = now()
    }
    
    final class func endWithTag(tag: String, additionalMessage message: String? = nil) {
        if let startTime = pendingEvents[tag] {
            let timeTaken = now() - startTime
            var result = "Timestamp - \(tag): \(timeTaken)"
            if let message = message {
                result += " \(message)"
            }
            print(result)
        }
    }
    
    private final class func now() -> CFTimeInterval {
        if #available(iOS 8.1, *) {
            return CFAbsoluteTimeGetCurrent()
        } else {
            return CACurrentMediaTime()
        }
    }
}
