//
//  SentPhotoViewCellCollectionViewCell.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 17..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class SentPhotoViewCell: PhotoViewCell {
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func initWithPhoto(photo: Photo) {
        super.initWithPhoto(photo)
        self.initStatusImageViewWithPhotoState(photo.photoState)
    }
    
    final func initStatusImageViewWithPhotoState(photoState: PhotoState) {
        let imgResourceName = photoState.sentStateImgResId
        statusImageView.image = UIImage(named: imgResourceName)
    }
    
    override func clear() {
        super.clear()
        statusImageView.image = nil
    }
}
