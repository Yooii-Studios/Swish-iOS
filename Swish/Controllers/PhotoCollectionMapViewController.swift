//
//  PhotoCollectionMapViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 19..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import MapKit

class PhotoCollectionMapViewController: BasePhotoMapViewController {
    
    enum PhotoType {
        case Sent
        case Received
    }
    
    final var photoType: PhotoType!
    
    override func viewDidLoad() {
        initPhotos()
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initPhotos() {
        switch photoType! {
        case .Sent:
            photos = SwishDatabase.sentPhotos().filter({ photo -> Bool in
                return photo.arrivedLocation != nil
            })
        case .Received:
            photos = SwishDatabase.receivedPhotos()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
