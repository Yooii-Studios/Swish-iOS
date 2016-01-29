//
//  PhotoTrendsViewCell.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 1. 29..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoTrendsViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    // TODO: 서클 버튼으로 변경 필요
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func initWithPhotoTrend(trendingPhoto: TrendingPhoto) {
        ImageDownloader.downloadImage(trendingPhoto.imageUrl) { [weak self] image in
            if let image = image {
                self?.photoImageView.image = image
            }
        }
        userNameLabel.text = trendingPhoto.owner.name
        ImageDownloader.downloadImage(trendingPhoto.owner.profileUrl) { [weak self] image in
            if let image = image {
                self?.userProfileImageView.image = image
            }
        }
        messageLabel.text = trendingPhoto.message
    }
    
    func clear() {
        photoImageView.image = nil
        userProfileImageView.image = nil
        userNameLabel.text = nil
        messageLabel.text = nil
        distanceLabel.text = nil
    }
    
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    */
}
