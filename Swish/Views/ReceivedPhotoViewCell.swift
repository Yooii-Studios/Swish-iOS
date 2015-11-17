//
//  ReceivedPhotoViewCell.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 4..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class ReceivedPhotoViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func initWithPhoto(photo: Photo) {
        PhotoImageHelper.imageWithPhoto(photo) { image in
            self.imageView.image = image
            self.userNameLabel.text = photo.sender.name
            self.messageLabel.text = photo.message
            // TODO: 거리 관련 유틸리티 추후 구현해서 적용할 것
            self.distanceLabel.text = "6230 km"
        }
    }
    
    func clear() {
        imageView.image = nil
        userNameLabel.text = nil
        distanceLabel.text = nil
        messageLabel.text = nil
    }
}
