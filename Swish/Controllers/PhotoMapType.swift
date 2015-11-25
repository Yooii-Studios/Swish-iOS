//
//  PhotoMapType.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

struct PhotoMapUserLocationTrackOption {
    let trackType: PhotoMapUserLocationTrackType
    let zoomLevel: MapViewZoomLevel
}

enum PhotoMapUserLocationTrackType {
    case None
    case OneShot
    case Follow
}

final class PhotoMapTypeHandler: NSObject, MKMapViewDelegate, LocationServiceAuthorizeDelegate {
    
    weak private final var photoMapType: PhotoMapType?
    private var hasUpdatedInitialUserLocation = false
    private var locationServiceAuthorizer: LocationServiceAuthorizer
    
    init(photoMapType: PhotoMapType) {
        self.locationServiceAuthorizer = LocationServiceAuthorizer()
        super.init()
        photoMapType.mapView.delegate = self
        self.photoMapType = photoMapType
        self.locationServiceAuthorizer.delegate = self
    }
    
    // MARK: - MapView Delegates
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        guard let photoMapUserLocationTrackOption = photoMapType?.photoMapUserLocationTrackOption else {
                return
        }
        let trackType = photoMapUserLocationTrackOption.trackType
        guard trackType != .None else {
            return
        }
        
        let shouldUpdateUserLocationOnMap = (trackType == .OneShot && !hasUpdatedInitialUserLocation)
            || trackType == .Follow
        if shouldUpdateUserLocationOnMap {
            mapView.setCenterCoordinate(userLocation.coordinate,
                withZoomLevel: photoMapUserLocationTrackOption.zoomLevel, animationType: .Normal)
        }
        hasUpdatedInitialUserLocation = true
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let id = "pin"
        var annotationView: MKAnnotationView!
        if let annotation = annotation as? PhotoAnnotation {
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(id) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
            } else {
                annotationView.annotation = annotation
            }
            annotationView.image = UIImage(named: annotation.imageName)
            annotationView.canShowCallout = true
        }
        
        return annotationView
    }
    
    func locationServiceAuthorized() {
        showsUserLocationOnMapView()
    }
    
    private func showsUserLocationOnMapView() {
        photoMapType?.mapView.showsUserLocation = true
    }
}

protocol PhotoMapType: class {
    weak var mapView: MKMapView! { get }
    var photos: [Photo]! { get }
    var photoMapUserLocationTrackOption: PhotoMapUserLocationTrackOption? { get }
    var photoMapTypeHandler: PhotoMapTypeHandler! { get }
}

extension PhotoMapType where Self: UIViewController {
    
    func requestLocationAuthorization() {
        if photoMapTypeHandler.locationServiceAuthorizer.locationManager.checkLocationAuthorizationStatus(self) {
            photoMapTypeHandler.showsUserLocationOnMapView()
        }
    }
    
    func initPhotoMapView() {
        addAnnotations()
    }
    
    private func addAnnotations() {
        for photo in photos {
            let location = displayLocationOfPhoto(photo)
            // TODO: 이미지를 사진으로 교체
            let annotation = PhotoAnnotation(coordinate: location.coordinate, imageName: "ic_sent_photo_waiting")
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func displayLocationOfPhoto(photo: Photo) -> CLLocation {
        return photo.isSentPhoto ? photo.arrivedLocation! : photo.departLocation
    }
}
