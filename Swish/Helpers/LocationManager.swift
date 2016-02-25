//
//  LocationManager.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 20..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationManager {
    
    static let dummyLocation = CLLocation(latitude: 36.01, longitude: 127.001)
    static var countryInfo: CountryInfo!
    
    final class func requestLocation(block: (location: CLLocation) -> Void) {
        // TODO: 실제 로직 구현해야 함. 현재는 더미 위치 리턴하도록 구현해 둠
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            NSThread.sleepForTimeInterval(NSTimeInterval(1))
            dispatch_async(dispatch_get_main_queue()) {
                block(location: dummyLocation)
            }
        }
    }
    
    final class func fetchCurrentCountryWithIP() {
        OutsideAPIServer.requestCountryInfo({ self.countryInfo = $0 }, onFail: { print($0) })
    }
}
