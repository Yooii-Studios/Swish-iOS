//
//  BasePhotoMapViewController.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import MapKit

class BasePhotoMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var photos: [Photo]!
    private var locationManager: CLLocationManager!
    
    // MARK: - View Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(photos)
        
        initMapView()
        addAnnotations()
        
        // 나중에 사용될 코드
        /*
        initLocationManager()
        requestCurrentLocation()
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initMapView() {
        mapView.delegate = self
    }
    
    private func addAnnotations() {
        for photo in photos {
            let coordinate: CLLocation! = photo.isSentPhoto ? photo.arrivedLocation : photo.departLocation
            // TODO: 이미지를 사진으로 교체
            let annotation = PhotoAnnotation(coordinate: coordinate.coordinate, imageName: "ic_sent_photo_waiting")
            
            mapView.addAnnotation(annotation)
        }
    }
    
    // 나중에 사용될 코드
    /*
    private func initLocationManager() {
    locationManager = CLLocationManager()
    locationManager.delegate = self
    }
    
    private func requestCurrentLocation() {
        print(CLLocationManager.locationServicesEnabled())
        print(CLLocationManager.authorizationStatus() == .NotDetermined)
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - LocationManager Delegates
    
    // TODO: LocationTrackable로 교체할 것
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            photoMapView.showsUserLocation = true
            //            mapView.userTrackingMode = .Follow
        }
    }
    
    // MARK: - MapView Delegates
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let region = MKCoordinateRegionMake(userLocation.coordinate, mapView.region.span)
        mapView.setRegion(region, animated: true)
    }
    */
    
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
    
    // MARK: - IBAction
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
