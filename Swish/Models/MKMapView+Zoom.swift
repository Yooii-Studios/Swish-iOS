//
//  MKMapView+Zoom.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 25..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import MapKit

typealias MapViewZoomLevel = Int

private let MaxZoomLevel = 20

enum MapViewAnimationType {
    case None
    case Normal
    case Fast
    
    var rawAnimated: Bool {
        return self != .None
    }
}

extension MKMapView {
    
    func setCenterCoordinate(coordinate: CLLocationCoordinate2D, withZoomLevel zoomLevel: MapViewZoomLevel,
        animationType: MapViewAnimationType) {
            executeBlock({
                self.setZoomLevel(coordinate, zoomLevel: zoomLevel, animationType: animationType)
                }, animationType: animationType)
    }
    
    func setZoomLevel(var coordinate: CLLocationCoordinate2D! = nil, zoomLevel: MapViewZoomLevel,
        animationType: MapViewAnimationType) {
            coordinate = coordinate ?? self.centerCoordinate
            executeBlock({
                let span = self.coordinateSpanWithCenterCoordinate(coordinate, zoomLevel: zoomLevel)
                self.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: animationType.rawAnimated)
                }, animationType: animationType)
    }
    
    private func executeBlock(block: () -> Void, animationType: MapViewAnimationType) {
        if animationType == .Fast {
            fastAnimate {
                block()
            }
        } else {
            block()
        }
    }
    
    private func fastAnimate(animation: () -> Void) {
        UIView.animateWithDuration(0.35, delay: 0.0, options: [.CurveLinear, .BeginFromCurrentState],
            animations: animation, completion: nil)
    }
    
    private func coordinateSpanWithCenterCoordinate(center: CLLocationCoordinate2D, zoomLevel: Int)
        -> MKCoordinateSpan {
            let centerMapPoint = MKMapPointForCoordinate(center)
            
            // determine the scale value from the zoom level
            let zoomExponent = MaxZoomLevel - min(zoomLevel, MaxZoomLevel);
            let zoomScale = pow(2.0, Double(zoomExponent))
            
            // scale the map’s size in pixel space
            let mapSizeInPixels = bounds.size
            let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
            let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
            
            // figure out the position of the top-left pixel
            let upperLeftMapPoint = MKMapPointMake(centerMapPoint.x - (scaledMapWidth / 2),
                centerMapPoint.y - (scaledMapHeight / 2))
            let lowerRightMapPoint = MKMapPointMake(upperLeftMapPoint.x + scaledMapWidth,
                upperLeftMapPoint.y + scaledMapHeight)
            
            let upperLeftCoordinage = MKCoordinateForMapPoint(upperLeftMapPoint)
            let lowerRightCoordinate = MKCoordinateForMapPoint(lowerRightMapPoint)
            
            // find delta between left and right longitudes
            let longitudeDelta = lowerRightCoordinate.longitude - upperLeftCoordinage.longitude
            
            // find delta between top and bottom latitudes
            let latitudeDelta = -1 * (lowerRightCoordinate.latitude - upperLeftCoordinage.latitude)
            
            // create and return the lat/lng span
            return MKCoordinateSpanMake(max(latitudeDelta, 0), max(longitudeDelta, 0))
    }
}
