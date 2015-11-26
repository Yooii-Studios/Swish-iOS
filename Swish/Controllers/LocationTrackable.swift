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

private func alertUnknownErrorWithViewController(viewController: UIViewController) {
    // TODO: 로컬라이징(title, message, Open, Cancel 부분). 일반적으로 비행기모드와 같이 인터넷(+cell)이 안되는 경우이므로
    // "알 수 없는 이유로 현재위치 가져올 수 없음. 인터넷 연결 확인 필요"라는 의미의 번역이 적합할듯
    let alertController = UIAlertController(title: "Cannot find current location",
        message: "Unknown error occurred. Check internet connection ", preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
    alertController.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.Default,
        handler: { action in
            SystemSettingsHelper.openSwishSystemSettings()
    }))
    viewController.showViewController(alertController, sender: nil)
}

final class LocationTrackHandler: NSObject, CLLocationManagerDelegate, LocationServiceAuthorizeDelegate {
    
    private var locationManager: CLLocationManager
    private var previousAuthStatus: CLAuthorizationStatus
    private var locationServiceAuthorizer: LocationServiceAuthorizer
    weak private final var locationTrackable: LocationTrackable?
    private var currentRootViewController: UIViewController? {
        return UIApplication.sharedApplication().keyWindow?.rootViewController
    }
    
    init(delegate: LocationTrackable?) {
        self.locationTrackable = delegate
        self.locationManager = CLLocationManager()
        self.previousAuthStatus = CLLocationManager.authorizationStatus()
        self.locationServiceAuthorizer = LocationServiceAuthorizer()
        super.init()
        self.locationManager.delegate = self
        self.locationServiceAuthorizer.delegate = self
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
    
    func locationServiceAuthorized() {
        if let locationTrackable = self.locationTrackable {
            notifyOrRequestLocationUpdate(locationTrackable)
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
        guard locationTrackHandler.locationManager.checkLocationAuthorizationStatus(self) else {
            return
        }
        notifyOrRequestLocationUpdate(self)
    }
    
    func requestLocationAuthorization() {
        locationTrackHandler.locationManager.checkLocationAuthorizationStatus(self)
    }
    
    func stopUpdatingLocation() {
        stopRequestLocation(locationTrackHandler.locationManager)
    }
}
