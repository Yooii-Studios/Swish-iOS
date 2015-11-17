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
    
    func clear() {
        imageView.image = nil
        messageLabel.text = nil
        statusImageView.image = nil
    }
}
