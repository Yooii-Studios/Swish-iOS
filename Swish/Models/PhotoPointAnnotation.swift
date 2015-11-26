//
//  PhotoPointAnnotation.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import MapKit

final class PhotoPointAnnotation: MKPointAnnotation {
    
    var photo: Photo
    
    init(coordinate: CLLocationCoordinate2D, photo: Photo) {
        self.photo = photo
        super.init()
        self.coordinate = coordinate
    }
}
