//
//  LocationServiceAuthorizable.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 25..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceAuthorizeDelegate {
    func locationServiceAuthorized()
}

class LocationServiceAuthorizer: NSObject, CLLocationManagerDelegate {
    
    var delegate: LocationServiceAuthorizeDelegate?
    var locationManager: CLLocationManager
    private var previousAuthStatus: CLAuthorizationStatus
    private var currentRootViewController: UIViewController? {
        return UIApplication.sharedApplication().keyWindow?.rootViewController
    }
    
    override init() {
        self.previousAuthStatus = CLLocationManager.authorizationStatus()
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != previousAuthStatus {
            if status == .NotDetermined || status == .Restricted {
                if let viewController = currentRootViewController {
                    manager.checkLocationAuthorizationStatus(viewController)
                }
            } else if status == .AuthorizedWhenInUse {
                delegate?.locationServiceAuthorized()
            }
        }
        previousAuthStatus = status
    }
}
