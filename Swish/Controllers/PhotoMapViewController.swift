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
    var photoMapTypeHandler: PhotoMapTypeHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conformPhotoMapType()
        
        initPhotoMapView()
        
        moveMapToInitialLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
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
        // TODO: span <-> zoom 변환로직 구현
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: mapView.region.span), animated: true)
    }
    
    func locationServiceEnabled() {
        mapView.showsUserLocation = true
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
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
