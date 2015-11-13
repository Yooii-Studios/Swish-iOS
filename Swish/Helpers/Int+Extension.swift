//
//  Int+Extension.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 11..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

extension Int {}

prefix func ++(inout value: Int?) -> Int? {
    if value != nil {
        value = value! + 1
    }
    return value
}
