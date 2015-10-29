//
//  List+Bridge.swift
//   Realm에서 사용되는 List 생성시 fundamental Array를 초기값으로 받는 생성자 추가
//
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
