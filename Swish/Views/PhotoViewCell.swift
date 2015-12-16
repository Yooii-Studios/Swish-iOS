//
//  PhotoViewCell.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 15..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

class PhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    private var photoId: Photo.ID!
    
    func initWithPhoto(photo: Photo) {
        photo.loadImage(imageType: .Thumbnail) { image in
            self.imageView.image = image
            self.messageLabel.text = photo.message
        }
        observeUnreadChatMessageCountForPhoto(photo)
    }
    
    func clear() {
        imageView.image = nil
        messageLabel.text = nil
        unobserveUnreadChatMessageCount()
    }
    
    deinit {
        unobserveUnreadChatMessageCount()
    }
    
    private func observeUnreadChatMessageCountForPhoto(photo: Photo) {
        photoId = photo.id
        PhotoObserver.observeUnreadMessageCountStreamForPhoto(photo) { unreadCount in
            // TODO: 읽지 않은 채팅 메시지 갯수 UI 업데이트 및 로그 삭제 필요
            print("\(photo.id)s unread message count: \(unreadCount)")
        }
    }
    
    private func unobserveUnreadChatMessageCount() {
        if let photoId = photoId {
            PhotoObserver.unobserveUnreadMessageCountStream(photoId)
        }
    }
}
