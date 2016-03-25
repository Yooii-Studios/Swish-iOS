//
//  WingsObservable.swift
//   Wings 객체의 변경을 감시할 수 있는 기능을 제공하는 protocol extension
//
//   Usage:
//    1. WingsObservable protocol을 conform하도록 아래 요구사항 구현
//      var wingsObserverTag: String { get } // WingsObservable를 사용하는 곳마다 unique한 값 필요
//
//      func wingsCountDidChange(wingCount: Int)
//      func wingsTimeLeftToChargeChange(timeLeftToCharge: Int?)
//
//    2. 필요한 곳에서 observeWingsChange(), stopObservingWingsChange() 호출
//    ex)
//      override func viewWillAppear(animated: Bool) {
//          observeWingsChange()
//      }
//
//      override func viewWillDisappear(animated: Bool) {
//          stopObservingWingsChange()
//      }
//
//  Swish
//
//  Created by 정동현 on 2015. 11. 12..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

protocol WingsObservable {
    
    var wingsObserverTag: String { get }
    
    func wingsCountDidChange(wingCount: Int)
    func wingsTimeLeftToChargeChange(timeLeftToCharge: Int?) // 충전이 다 된 경우 시간이 아닌 nil을 반환
}

extension WingsObservable {
    
    func observeWingsChange() {
        WingsObserver.instance.observeWingCountWithTag(tag: wingsObserverTag) { wingCount in
            self.wingsCountDidChange(wingCount)
        }
        WingsObserver.instance.observeTimeLeftToChargeWithTag(tag: wingsObserverTag) { timeLeftToCharge in
            self.wingsTimeLeftToChargeChange(timeLeftToCharge)
        }
    }
    
    func stopObservingWingsChange() {
        WingsObserver.instance.cancelObserveWingCountWithTag(tag: wingsObserverTag)
        WingsObserver.instance.cancelObserveTimeLeftToChargeWithTag(tag: wingsObserverTag)
    }
}
