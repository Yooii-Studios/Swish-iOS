//
//  LocationTrackable.swift
//   UIViewController에서 구현해 현재 위치를 구할 수 있는 기능을 제공하는 protocol extension
//
//   Usage:
//    1. LocationTrackable protocol을 conform하도록 아래 요구사항 구현
//      var locationTrackType: LocationTrackType { get }
//      var locationTrackHandler: LocationTrackHandler! { get }
//
//      func locationDidUpdate(location: CLLocation)
//      func authorizationDidFailed(status: CLAuthorizationStatus)
//        -> status를 체크, 실패 원인에 따른 예외처리 호출부에서 구현 필요
//
//    2. LocationTrackHandler 인스턴스 생성
//      override func viewDidLoad() {
//          super.viewDidLoad()
//
//          locationTrackHandler = LocationTrackHandler(delegate: self)
//      }
//
//    3. 필요한 곳에서 requestLocationUpdate(), stopUpdatingLocation() 호출
//    ex)
//      override func viewWillAppear(animated: Bool) {
//          requestLocationUpdate()
//      }
//
//      override func viewWillDisappear(animated: Bool) {
//          stopUpdatingLocation()
//      }
//
//  Swish
//
//  Created by 정동현 on 2015. 10. 29..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

enum LocationTrackType {
    case OneShot
    case Track
}

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
    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,
        handler: nil))
    alertController.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.Default,
        handler: { action in
            openSwishSettingsInSystemSettings()
    }))
    viewController.showViewController(alertController, sender: nil)
}

private func openSwishSettingsInSystemSettings() {
    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
    }
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
    
    // MARK: - Delegate functions
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations: \(locations)")
        locationTrackable?.locationDidUpdate(locations.last!)
        if locationTrackable?.locationTrackType == .OneShot {
            stopRequestLocation(manager)
        }
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
        let status = CLLocationManager.authorizationStatus()
        guard status != .NotDetermined else {
            // TODO: 로컬라이징.유저에게 현재위치 사용 요청하는 다이얼로그를 띄워주는 부분.
            // info.plist의 NSLocationWhenInUseUsageDescription 키에 해당하는 값을 다국어 번역해야함
            print("Requesting location service...")
            locationTrackHandler.locationManager.requestWhenInUseAuthorization()
            return
        }
        guard status == .AuthorizedWhenInUse else {
            alertLocationServiceWithViewController(self, status: status)
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
