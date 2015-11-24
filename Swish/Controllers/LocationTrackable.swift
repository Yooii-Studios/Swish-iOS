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
//      override func viewDidAppear(animated: Bool) {
//          requestLocationUpdate()
//      }
//
//      override func viewDidDisappear(animated: Bool) {
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

private func checkLocationAuthorizationStatus(locationTrackable: LocationTrackable,
    viewController: UIViewController) -> Bool{
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
            locationTrackable.locationTrackHandler.locationManager.requestWhenInUseAuthorization()
            return false
        }
        guard status == .AuthorizedWhenInUse else {
            alertLocationServiceWithViewController(viewController, status: status)
            return false
        }
        return true
}

private func notifyOrRequestLocationUpdate(locationTrackable: LocationTrackable) {
    // cache가 있고 one shot인 경우 위치를 요청할 필요가 없으므로 알린 후 끝냄
    let locationTrackHandler = locationTrackable.locationTrackHandler
    let locationTrackType = locationTrackable.locationTrackType
    
    if let recentLocation = locationTrackHandler.locationManager.location where locationTrackType == .OneShot {
        print("recent location:\(recentLocation)")
        locationTrackable.locationDidUpdate(recentLocation)
    } else {
        requestLocationUpdate(locationTrackHandler.locationManager, locationTrackType: locationTrackType)
    }
}

private func requestLocationUpdate(locationManager: CLLocationManager, locationTrackType: LocationTrackType) {
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
    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
    alertController.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.Default,
        handler: { action in
            openSwishSystemSettings()
    }))
    viewController.showViewController(alertController, sender: nil)
}

private func alertUnknownErrorWithViewController(viewController: UIViewController) {
    // TODO: 로컬라이징(title, message, Open, Cancel 부분). 일반적으로 비행기모드와 같이 인터넷(+cell)이 안되는 경우이므로
    // "알 수 없는 이유로 현재위치 가져올 수 없음. 인터넷 연결 확인 필요"라는 의미의 번역이 적합할듯
    let alertController = UIAlertController(title: "Cannot find current location",
        message: "Unknown error occurred. Check internet connection ", preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
    alertController.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.Default,
        handler: { action in
            openSwishSystemSettings()
    }))
    viewController.showViewController(alertController, sender: nil)
}

private func openSwishSystemSettings() {
    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
    }
}

final class LocationTrackHandler: NSObject, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager
    private var previousAuthStatus: CLAuthorizationStatus
    weak private final var locationTrackable: LocationTrackable?
    
    init(delegate: LocationTrackable?) {
        self.locationTrackable = delegate
        self.locationManager = CLLocationManager()
        self.previousAuthStatus = CLLocationManager.authorizationStatus()
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManager didFailWithError: \(error)")
        if let viewController = currentRootViewController {
            alertUnknownErrorWithViewController(viewController)
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if let locationTrackable = locationTrackable where status != previousAuthStatus {
            if status == .NotDetermined || status == .Restricted {
                if let viewController = currentRootViewController {
                    checkLocationAuthorizationStatus(locationTrackable, viewController: viewController)
                }
            } else if status == .AuthorizedWhenInUse {
                notifyOrRequestLocationUpdate(locationTrackable)
            }
        }
        previousAuthStatus = status
    }
    
    var currentRootViewController: UIViewController? {
        return UIApplication.sharedApplication().keyWindow?.rootViewController
    }
}

protocol LocationTrackable: class {
    
    var locationTrackType: LocationTrackType { get }
    var locationTrackHandler: LocationTrackHandler! { get }
    
    func locationDidUpdate(location: CLLocation)
}

extension LocationTrackable where Self: UIViewController {
    
    func requestLocationUpdate() {
        guard checkLocationAuthorizationStatus(self, viewController: self) else {
            return
        }
        notifyOrRequestLocationUpdate(self)
    }
    
    func stopUpdatingLocation() {
        stopRequestLocation(locationTrackHandler.locationManager)
    }
}
