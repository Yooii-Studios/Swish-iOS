//
//  CLLocationDistance+Unit.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 1..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationDistance {
    
    var inKilometers: CLLocationDistance {
        return self / 1000
    }
    
    var inMiles: CLLocationDistance {
        return self * 0.000621371
    }
}
