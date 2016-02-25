//
//  PhotoViewCell.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 15..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftTask

class PhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chatIndicatorView: ChatIndicatorView!
    private var photoId: Photo.ID!
    private var observeCanceller: Canceller?
    
    func initWithPhoto(photo: Photo) {
        photo.loadImage(imageType: .Thumbnail) { image in
            self.imageView.image = image
            self.messageLabel.text = photo.message
        }
        observeUnreadChatMessageCountForPhoto(photo)
        chatIndicatorView.setUpWithPhoto(photo)
    }
    
    func clear() {
        imageView.image = nil
        messageLabel.text = nil
        
        unobserveUnreadChatMessageCount()
    }
    
    private func observeUnreadChatMessageCountForPhoto(photo: Photo) {
        observeCanceller = PhotoObserver.observeUnreadMessageCountForPhoto(photo, owner: self,
            handler: { [weak self] unreadCount in
                self?.chatIndicatorView.setUnreadChatCount(unreadCount)
        })
    }
    
    private func unobserveUnreadChatMessageCount() {
        observeCanceller?.cancel()
    }
}
