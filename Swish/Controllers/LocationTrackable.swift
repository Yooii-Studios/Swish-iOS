//
//  LocationTrackable.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 29..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

enum LocationTrackType { case OneShot, Track }

private func requestLocation(locationManager: CLLocationManager, locationTrackType: LocationTrackType) {
    if #available(iOS 9.0, *), locationTrackType == .OneShot {
        locationManager.requestLocation()
    } else {
        locationManager.startUpdatingLocation()
    }
}

private func stopRequestLocation(locationManager: CLLocationManager) {
    locationManager.stopUpdatingLocation()
}

final class LocationTrackHandler: NSObject, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager
    weak private final var locationTrackable: LocationTrackable?
    
    init(delegate: LocationTrackable?) {
        self.locationTrackable = delegate
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard status == .AuthorizedWhenInUse else {
            print("authorization failed")
            return
        }
        print("authorization success")
        guard let locationTrackType = locationTrackable?.locationTrackType else {
            return
        }
        requestLocation(manager, locationTrackType: locationTrackType)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations: \(locations)")
        locationTrackable?.locationDidUpdate(locations.last!)
        if locationTrackable?.locationTrackType == .OneShot {
            stopRequestLocation(manager)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManager didFailWithError")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("didUpdateHeading")
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates")
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        print("locationManagerDidResumeLocationUpdates")
    }
    
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        print("didFinishDeferredUpdatesWithError")
    }
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        print("didVisit")
    }
}

protocol LocationTrackable: class {
    
    var locationTrackType: LocationTrackType { get }
    var locationTrackHandler: LocationTrackHandler! { get }
    
    func locationDidUpdate(location: CLLocation)
}

extension LocationTrackable where Self: UIViewController {
    
    func requestLocationUpdate() {
        guard CLLocationManager.locationServicesEnabled() else {
            // TODO: 디바이스의 상태가 위치 서비스를 사용할 수 없는 상황. 예외처리가 필요시 예외처리 추가
            print("locationService disabled")
            return
        }
        guard CLLocationManager.authorizationStatus() != .NotDetermined else {
            // TODO: 유저에게 현재위치 사용 요청하는 다이얼로그를 띄워주는 부분. info.plist의 NSLocationWhenInUseUsageDescription 키에
            // 해당하는 값을 다국어 번역해야함
            print("locationService not authorized. Requesting...")
            locationTrackHandler.locationManager.requestWhenInUseAuthorization()
            return
        }
        // cache가 있고 one shot인 경우 위치를 요청할 필요가 없으므로 알린 후 끝냄
        if let recentLocation = locationTrackHandler.locationManager.location where locationTrackType == .OneShot {
            print("recent location:\(recentLocation)")
            locationDidUpdate(recentLocation)
        } else {
            requestLocation(locationTrackHandler.locationManager, locationTrackType: locationTrackType)
        }
    }
    
    func stopUpdatingLocation() {
        stopRequestLocation(locationTrackHandler.locationManager)
    }
}
