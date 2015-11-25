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
    final var photoType: PhotoType!
    var photos: [Photo]!
    var photoMapUserLocationTrackOption: PhotoMapUserLocationTrackOption?
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
        
        photoMapUserLocationTrackOption = PhotoMapUserLocationTrackOption(trackType: .OneShot, zoomLevel: 10)
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
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
