//
//  PhotoCardView.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 28..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable
import AlamofireImage

@IBDesignable
class PhotoCardView: NibDesignable {

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userIdLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var departInfoLabel: UILabel!
    
    // MARK: - Initalize
    
    final func setUpWithPhoto(photo: Photo) {
        setUpPhotoImage(photo)
        setUpUserViews(photo)
        setUpDepartInfoLabel(photo)
    }
    
    private func setUpPhotoImage(photo: Photo) {
        photo.loadImage { image in
            self.photoImageView.image = image
        }
    }
    
    private func setUpUserViews(photo: Photo) {
        ImageDownloader.downloadImage(photo.sender.profileUrl) { image in
            if let image = image {
                self.profileImageView.image = image
            }
        }
        userIdLabel.text = photo.sender.name
        messageLabel.text = photo.message
    }
    
    private func setUpDepartInfoLabel(photo: Photo) {
        departInfoLabel.text = (photo.departCountry ?? "").isEmpty ?
                photo.deliveredDistanceString : photo.departCountry
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
