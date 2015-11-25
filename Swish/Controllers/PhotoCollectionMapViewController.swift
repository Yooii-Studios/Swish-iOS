//
//  PhotoCollectionMapViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 19..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import MapKit

class PhotoCollectionMapViewController: UIViewController, PhotoMapType {
    
    enum PhotoType {
        case Sent
        case Received
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoMapMyLocationButton: UIButton!
    final var photoType: PhotoType!
    var photos: [Photo]!
    var photoMapViewZoomLevel: MapViewZoomLevel = PhotoMapMinZoomLevel
    var photoMapUserLocationTrackType: PhotoMapUserLocationTrackType? = .OneShot
    var photoMapTypeHandler: PhotoMapTypeHandler!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conformPhotoMapType()
        
        initPhotoMapView()
    }
    
    override func viewDidAppear(animated: Bool) {
        requestLocationAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func conformPhotoMapType() {
        switch photoType! {
        case .Sent:
            photos = SwishDatabase.sentPhotos().filter({ photo -> Bool in
                return photo.arrivedLocation != nil
            })
        case .Received:
            photos = SwishDatabase.receivedPhotos()
        }
        
        photoMapTypeHandler = PhotoMapTypeHandler(photoMapType: self)
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
    
    @IBAction func photoMapMyLocationButtonDidTap(sender: AnyObject) {
        moveToMyLocation()
    }
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
