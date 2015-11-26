//
//  PhotoMapType.swift
//   Usage:
//    1. PhotoMapType protocol을 conform하도록 아래 요구사항 구현
//      weak var mapView: MKMapView! { get }
//      weak var photoMapMyLocationButton: UIButton! { get }
//      var photos: [Photo]! { get }
//      var photoMapViewZoomLevel: MapViewZoomLevel { get set }
//      var photoMapUserLocationTrackType: PhotoMapUserLocationTrackType? { get }
//      var photoMapTypeHandler: PhotoMapTypeHandler! { get }
//
//    2. 초기화
//      var photoMapViewZoomLevel: MapViewZoomLevel = PhotoMapMaxZoomLevel
//      var photoMapUserLocationTrackType: PhotoMapUserLocationTrackType? = .OneShot
//
//      override func viewDidLoad() {
//          super.viewDidLoad()
//
//          photos = SwishDatabase.receivedPhotos()
//          photoMapTypeHandler = PhotoMapTypeHandler(photoMapType: self)
//      }
//
//    3. viewDidAppear에서 requestLocationAuthorization() 호출
//    ex)
//      override func viewDidAppear(animated: Bool) {
//          requestLocationAuthorization()
//      }
//    4. 필요한 곳에서 아래의 메서드 사용
//      @IBAction func photoMapZoomInButtonDidTap(sender: AnyObject) {
//          zoomInPhotoMapView()
//      }
//
//      @IBAction func photoMapZoomOutButtonDidTap(sender: AnyObject) {
//          zoomOutPhotoMapView()
//      }
//
//      @IBAction func photoMapMyLocationButtonDidTap(sender: AnyObject) {
//          movePhotoMapViewToMyLocation()
//      }
//
//
//  Swish
//
//  Created by 정동현 on 2015. 11. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

enum PhotoMapUserLocationTrackType {
    case None
    case OneShot
    case Follow
}

let PhotoMapMaxZoomLevel = 8
let PhotoMapMinZoomLevel = 2

final class PhotoMapTypeHandler: NSObject, MKMapViewDelegate, LocationServiceAuthorizeDelegate {
    
    weak private final var photoMapType: PhotoMapType?
    private var hasUpdatedInitialUserLocation = false
    private var locationServiceAuthorizer: LocationServiceAuthorizer
    
    init(photoMapType: PhotoMapType) {
        self.locationServiceAuthorizer = LocationServiceAuthorizer()
        super.init()
        photoMapType.mapView.zoomEnabled = false
        photoMapType.mapView.delegate = self
        photoMapType.photoMapMyLocationButton.hidden = true
        self.photoMapType = photoMapType
        self.locationServiceAuthorizer.delegate = self
    }
    
    // MARK: - MapView Delegates
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        guard let photoMapType = photoMapType else {
            return
        }
        guard let trackType = photoMapType.photoMapUserLocationTrackType where trackType != .None else {
            return
        }
        
        let shouldUpdateUserLocationOnMap = (trackType == .OneShot && !hasUpdatedInitialUserLocation)
            || trackType == .Follow
        if shouldUpdateUserLocationOnMap {
            mapView.setCenterCoordinate(userLocation.coordinate,
                withZoomLevel: photoMapType.photoMapViewZoomLevel.normalizedValue, animationType: .Normal)
        }
        hasUpdatedInitialUserLocation = true
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let id = "pin"
        var annotationView: MKAnnotationView!
        if let annotation = annotation as? PhotoPointAnnotation {
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
        photoMapType?.photoMapMyLocationButton.hidden = false
        photoMapType?.mapView.showsUserLocation = true
    }
}

protocol PhotoMapType: class {
    weak var mapView: MKMapView! { get }
    weak var photoMapMyLocationButton: UIButton! { get }
    var photos: [Photo]! { get }
    var photoMapViewZoomLevel: MapViewZoomLevel { get set }
    var photoMapUserLocationTrackType: PhotoMapUserLocationTrackType? { get }
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
            let annotation = PhotoPointAnnotation(coordinate: location.coordinate, imageName: "ic_sent_photo_waiting")
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func displayLocationOfPhoto(photo: Photo) -> CLLocation {
        return photo.isSentPhoto ? photo.arrivedLocation! : photo.departLocation
    }
    
    func zoomInPhotoMapView() {
        mapView.setZoomLevel(zoomLevel: ++?photoMapViewZoomLevel, animationType: .Fast)
    }
    
    func zoomOutPhotoMapView() {
        mapView.setZoomLevel(zoomLevel: --?photoMapViewZoomLevel, animationType: .Fast)
    }
    
    func movePhotoMapViewToMyLocation() {
        if let location = mapView.userLocation.location {
            mapView.setCenterCoordinate(location.coordinate, withZoomLevel: photoMapViewZoomLevel.normalizedValue, animationType: .Normal)
            mapView.setCenterCoordinate(location.coordinate, animated: true)
        }
    }
}

// MARK: - Normalized Zoom Level Helper Functions

prefix operator ++? {}
prefix operator --? {}

private prefix func ++?(inout zoomLevel: MapViewZoomLevel) -> MapViewZoomLevel {
    zoomLevel = normalizeZoomLevel(++zoomLevel)
    return zoomLevel
}

private prefix func --?(inout zoomLevel: MapViewZoomLevel) -> MapViewZoomLevel {
    zoomLevel = normalizeZoomLevel(--zoomLevel)
    return zoomLevel
}

private func normalizeZoomLevel(zoomLevel: MapViewZoomLevel) -> MapViewZoomLevel {
    return max(min(zoomLevel, PhotoMapMaxZoomLevel), PhotoMapMinZoomLevel)
}

private extension MapViewZoomLevel {
    
    var normalizedValue: MapViewZoomLevel {
        return normalizeZoomLevel(self)
    }
}
