//
//  PhotoMapViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 19..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, PhotoMapType {
    
    @IBOutlet weak var mapView: MKMapView!
    var photos: [Photo]!
    var photoId: Photo.ID!
    var photoMapViewZoomLevel: MapViewZoomLevel = PhotoMapMaxZoomLevel
    var photoMapUserLocationTrackType: PhotoMapUserLocationTrackType?
    var photoMapTypeHandler: PhotoMapTypeHandler!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conformPhotoMapType()
        
        initPhotoMapView()
    }
    
    override func viewDidAppear(animated: Bool) {
        moveMapToInitialLocation()
        requestLocationAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func conformPhotoMapType() {
        photos = [Photo]()
        photos.append(SwishDatabase.photoWithId(photoId!)!)
        
        photoMapTypeHandler = PhotoMapTypeHandler(photoMapType: self)
    }
    
    private func moveMapToInitialLocation() {
        let location = displayLocationOfPhoto(photos[0])
        mapView.setCenterCoordinate(location.coordinate, withZoomLevel: photoMapViewZoomLevel, animationType: .Normal)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IBAction
    
    // TODO: 스토리보드에 임의로 넣어둔 버튼 수정 필요
    @IBAction func photoMapZoomInButtonDidTap(sender: AnyObject) {
        zoomInPhotoMapView()
    }
    
    @IBAction func photoMapZoomOutButtonDidTap(sender: AnyObject) {
        zoomOutPhotoMapView()
    }
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
