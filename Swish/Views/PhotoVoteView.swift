//
//  PhotoVoteView.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 16..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable

@IBDesignable
class PhotoVoteView: NibDesignable {

    @IBOutlet var likeButton: CircleButton!
    @IBOutlet var dislikeButton: CircleButton!
    
    private var photoId: Photo.ID = -1
    
    final func setUpWithPhotoId(photoId: Photo.ID, withPhotoState photoState: PhotoState) {
        setUpPhotoId(photoId)
        setUpButtonsWithPhotoState(photoState)
        setUpTapGestures()
    }
    
    private func setUpPhotoId(photoId: Photo.ID) {
        self.photoId = photoId
    }
    
    private func setUpButtonsWithPhotoState(photoState: PhotoState) {
        if photoState == .Liked {
            setLikeButtonSelected()
            setDislikeButtonDisabled()
        } else if photoState == .Disliked {
            setLikeButtonDisabled()
            setDislikeButtonSelected()
        } else {
            setButtonsUnSelected()
        }
    }
    
    private func setUpTapGestures() {
        let likeButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(likeButtonDidTap(_:)))
        likeButton.addGestureRecognizer(likeButtonTapGesture)
        
        let dislikeButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(dislikeButtonDidTap(_:)))
        dislikeButton.addGestureRecognizer(dislikeButtonTapGesture)
    }
    
    private func setLikeButtonSelected() {
        likeButton.setSelected(true)
        likeButton.image = UIImage(named: "ic_photo_like_active")
        likeButton.userInteractionEnabled = false
        
        dislikeButton.setSelected(false)
        dislikeButton.image = UIImage(named: "ic_photo_dislike_inactive")
        dislikeButton.userInteractionEnabled = true
    }
    
    private func setLikeButtonDisabled() {
        likeButton.setDisabled()
    }
    
    private func setDislikeButtonSelected() {
        likeButton.setSelected(false)
        likeButton.image = UIImage(named: "ic_photo_like_inactive")
        likeButton.userInteractionEnabled = true
        
        dislikeButton.setSelected(true)
        dislikeButton.image = UIImage(named: "ic_photo_dislike_active")
        dislikeButton.userInteractionEnabled = false
    }
    
    private func setDislikeButtonDisabled() {
        dislikeButton.setDisabled()
    }
    
    private func setButtonsUnSelected() {
        likeButton.setSelected(false)
        likeButton.image = UIImage(named: "ic_photo_like_inactive")
        likeButton.userInteractionEnabled = true
        
        dislikeButton.setSelected(false)
        dislikeButton.image = UIImage(named: "ic_photo_dislike_inactive")
        dislikeButton.userInteractionEnabled = true
    }
    
    final func likeButtonDidTap(sender: AnyObject) {
        setLikeButtonSelected()
        updatePhotoState(.Liked)
    }
    
    final func dislikeButtonDidTap(sender: AnyObject) {
        setDislikeButtonSelected()
        updatePhotoState(.Disliked)
    }
    
    private func updatePhotoState(photoState: PhotoState) {
        let photoStateUpdateRequest = PhotoStateUpdateRequest(photoId: photoId, state: photoState)
        PhotoStateUpdater.instance.registerUpdateRequest(photoStateUpdateRequest)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
