//
//  SentPhotoViewCellCollectionViewCell.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 17..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class SentPhotoViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    func initWithPhoto(photo: Photo) {
        photo.loadImage(imageType: .Thumbnail) { image in
            self.imageView.image = image
            self.messageLabel.text = photo.message
            self.initStatusImageViewWithPhotoState(photo.photoState)
        }
    }
    
    func initStatusImageViewWithPhotoState(photoState: PhotoState) {
        let imgResourceName = photoState.sentStateImgResourceName
        statusImageView.image = UIImage(named: imgResourceName)
    }
    
    func clear() {
        imageView.image = nil
        messageLabel.text = nil
        statusImageView.image = nil
    }
}
