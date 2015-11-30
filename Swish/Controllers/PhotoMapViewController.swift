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
    @IBOutlet weak var photoMapMyLocationButton: UIButton!
    var photos: [Photo]!
    var photoId: Photo.ID!
    var photoMapViewZoomLevel: MapViewZoomLevel = PhotoMapMaxZoomLevel
    var photoMapUserLocationTrackType: PhotoMapUserLocationTrackType?
    var photoMapTypeHandler: PhotoMapTypeHandler!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPhotos()
        initPhotoMapTypeHandler()
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
    
    private func initPhotos() {
        photos = [Photo]()
        // TODO: 원래는 필요 없는 구현이지만 받은 / 보낸 사진 상세 정보 화면 구현이 덜 되어 그 전까지 임의의 사진을 보여주도록 구성.
        // TODO: 받은 / 보낸 사진 상세 정보 화면이 구현된 후 아래의 if문 삭제 필요
        if photoId == nil || photoId! == -1 {
            let receivedPhotos = SwishDatabase.receivedPhotos()
            let sentPhotos = SwishDatabase.sentPhotos()
            if receivedPhotos.count > 0 {
                photos.append(receivedPhotos[0])
            } else if sentPhotos.count > 0 {
                photos.append(sentPhotos[0])
            } else {
                assertionFailure("Must have at least 1 photo to test this functionality!!!")
            }
        } else {
            photos.append(SwishDatabase.photoWithId(photoId!)!)
        }
    }
    
    private func initPhotoMapTypeHandler() {
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
    
    @IBAction func photoMapMyLocationButtonDidTap(sender: AnyObject) {
        movePhotoMapViewToMyLocation()
    }
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
