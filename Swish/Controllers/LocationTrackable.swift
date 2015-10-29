//
//  LocationTrackable.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 29..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

enum LocationTrackType { case OneShot, Track }

final class LocationTrackHandler: NSObject, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager
    weak private final var delegate: LocationTrackable?
    
    init(delegate: LocationTrackable?) {
        self.delegate = delegate
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations: \(locations)")
        delegate?.locationDidUpdate(locations.last!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManager didFailWithError")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
        if status == .AuthorizedWhenInUse {
            print("authorization success")
            manager.startUpdatingLocation()
            //            if #available(iOS 9.0, *) {
            //                locationManager.requestLocation()
            //            } else {
            //                locationManager.startMonitoringSignificantLocationChanges()
            //            }
        } else {
            print("authorization failed")
        }
    }
    
    //    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    //
    //    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    //
    //    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool
    //
    //    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion)
    //
    //    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    //
    //    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError)
    //
    //    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion)
    //
    //    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion)
    //
    //    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    //
    //    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)
    //
    //    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    //
    //    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion)
    //
    //    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager)
    //
    //    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager)
    //
    //    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?)
    //    
    //    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit)
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
        locationTrackHandler.locationManager.startUpdatingLocation()
        print("recent location:\(locationTrackHandler.locationManager.location)")
    }
    
    func stopUpdatingLocation() {
        locationTrackHandler.locationManager.stopUpdatingLocation()
    }
}
