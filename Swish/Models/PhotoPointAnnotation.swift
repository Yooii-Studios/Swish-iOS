//
//  PhotoPointAnnotation.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import MapKit

final class PhotoAnnotation: MKPointAnnotation {
    
    var imageName: String
    
    init(coordinate: CLLocationCoordinate2D, imageName: String) {
        self.imageName = imageName
        super.init()
        self.coordinate = coordinate
    }
}
