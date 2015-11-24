//
//  CLLocationManager+Authorization.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 24..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationManager {
    
    func checkLocationAuthorizationStatus(viewController: UIViewController) -> Bool {
            guard CLLocationManager.locationServicesEnabled() else {
                // TODO: 디바이스의 상태가 위치 서비스를 사용할 수 없는 상황. 예외처리가 필요시 예외처리 추가
                print("locationService disabled")
                return false
            }
            let status = CLLocationManager.authorizationStatus()
            guard status != .NotDetermined else {
                // TODO: 로컬라이징.유저에게 현재위치 사용 요청하는 다이얼로그를 띄워주는 부분.
                // info.plist의 NSLocationWhenInUseUsageDescription 키에 해당하는 값을 다국어 번역해야함
                print("Requesting location service...")
                requestWhenInUseAuthorization()
                return false
            }
            guard status == .AuthorizedWhenInUse else {
                alertLocationServiceWithViewController(viewController, status: status)
                return false
            }
            return true
    }
    
    private func alertLocationServiceWithViewController(viewController: UIViewController, status: CLAuthorizationStatus) {
        // TODO: 로컬라이징
        // TODO: 메시지 통일될 경우 메서드 내에서 사용하도록 변경
        if status == .Denied {
            alertLocationServiceWithViewController(viewController, title: "Denied", message: "Settings -> blah -> blah")
        } else if status == .Restricted {
            alertLocationServiceWithViewController(viewController, title: "Restricted", message: "Settings -> blah -> blah")
        }
    }
    
    private func alertLocationServiceWithViewController(viewController: UIViewController, title: String, message: String) {
        // TODO: 로컬라이징(Open, Cancel 부분)
        let alertController = UIAlertController(title: title,
            message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.Default,
            handler: { action in
                SystemSettingsHelper.openSwishSystemSettings()
        }))
        viewController.showViewController(alertController, sender: nil)
    }
}
