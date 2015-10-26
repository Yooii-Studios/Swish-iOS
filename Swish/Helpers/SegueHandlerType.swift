//
//  SegueHandlerType.swift
//   UIViewController에서 segueIdentifier를 enum으로 래핑해서 쓸 수 있게 만들어주는 Protocol
//
//  1. UIViewController 및 sublcass 에 SegueHandlerType 프로토콜 추가
//
//  2. 해당 UIViewController 에 상단부에 사용될 enum SegueIdentifier 선언
//
//        enum SegueIdentifier: String {
//            case ShowShareResult
//        }
//
//  3. performSegueWithIdentifier() 메서드는 아래 래핑된 extension의 메서드를 대신 사용하고,
//     prepareForSegue() 메서드는 다음과 같이 사용(from DressingViewController)
//     segueIdentifierForSegue()도 extension에서 구현
//
//        switch segueIdentifierForSegue(segue) {
//        case .ShowShareResult:
//            // Do something
//        }
//
//  자세한 내용은 WWDC 2015 세션 415 - Swift in Practice을 참고
//  https://developer.apple.com/videos/play/wwdc2015-411/
//
//
//  Swish
//
//  Created by Wooseong Kim on 2015. 10. 24..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

protocol SegueHandlerType {
    
    typealias SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegueWithIdentifier(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegueWithIdentifier(segueIdentifier.rawValue, sender: sender)
    }

    func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
                  segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            // TODO: 출시 전에 Crashylitics로 옮긴다거나 하는 부분 동현과 의논 필요
            fatalError("Couldn't handle segue identifier \(segue.identifier) for view controller of type \(self.dynamicType).")
        }
        
        return segueIdentifier
    }
}
