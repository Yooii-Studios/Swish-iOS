//
//  List+Bridge.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 21..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import RealmSwift

extension List {
    
    convenience init(initialArray: Array<T>?) {
        self.init()
        if let initialArray = initialArray {
            appendContentsOf(initialArray)
        }
    }
}
