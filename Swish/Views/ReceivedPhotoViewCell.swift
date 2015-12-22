//
//  ReceivedPhotoViewCell.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 4..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class ReceivedPhotoViewCell: PhotoViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    private var photoId: Photo.ID!
    
    override func initWithPhoto(photo: Photo) {
        super.initWithPhoto(photo)
        self.userNameLabel.text = photo.sender.name
        self.distanceLabel.text = photo.deliveredDistanceString
    }
    
    override func clear() {
        super.clear()
        userNameLabel.text = nil
        distanceLabel.text = nil
    }
}
