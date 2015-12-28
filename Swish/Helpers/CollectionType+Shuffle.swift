//
//  CollectionType+Shuffle.swift
//    Source: http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
//
//  Swish
//
//  Created by 정동현 on 2015. 12. 28..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

extension CollectionType {
    
    // 셔플된 복사본 생성
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    
    // 컬랙션 타입이 스스로를 셔플
    mutating func shuffleInPlace() {
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
