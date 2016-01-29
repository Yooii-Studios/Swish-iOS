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
        loadPhotoImageWithUrl(trendingPhoto.imageUrl)
        initUserUI(trendingPhoto.owner)
        initMessageLabel(trendingPhoto.message)
        initDistanceLabel()
    }
    
    private func loadPhotoImageWithUrl(url: String) {
        ImageDownloader.downloadImage(url) { [weak self] image in
            if let image = image {
                self?.photoImageView.image = image
            }
        }
    }
    
    private func initUserUI(user: User) {
        userNameLabel.text = user.name
        ImageDownloader.downloadImage(user.profileUrl) { [weak self] image in
            if let image = image {
                self?.userProfileImageView.image = image
            }
        }
    }
    
    private func initMessageLabel(message: String) {
        messageLabel.text = message
    }
    
    private func initDistanceLabel() {
        // TODO: 추후 포토 트렌즈 VC의 현재 위치와 연계해 구현 필요
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
