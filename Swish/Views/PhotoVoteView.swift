//
//  PhotoVoteView.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 16..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable

class PhotoVoteView: NibDesignable {

    @IBOutlet var likeButton: CircleButton!
    @IBOutlet var dislikeButton: CircleButton!
    
    private var photoId: Photo.ID = -1
    
    final func setUpWithPhotoId(photoId: Photo.ID, withPhotoState photoState: PhotoState) {
        setUpButtonsWithPhotoState(photoState)
        setUpTapGestures()
    }
    
    private func setUpButtonsWithPhotoState(photoState: PhotoState) {
        if photoState == .Liked {
            setLikeButtonSelected()
            setDislikeButtonDisabled()
        } else if photoState == .Disliked {
            setLikeButtonDisabled()
            setDislikeButtonSelected()
        }
    }
    
    private func setUpTapGestures() {
        let likeButtonTapGesture = UITapGestureRecognizer(target: self, action: "likeButtonDidTap:")
        likeButton.addGestureRecognizer(likeButtonTapGesture)
        
        let dislikeButtonTapGesture = UITapGestureRecognizer(target: self, action: "dislikeButtonDidTap:")
        dislikeButton.addGestureRecognizer(dislikeButtonTapGesture)
    }
    
    private func setLikeButtonSelected() {
        // TODO: imageView 부분은 CircleButton xib 리팩터링 이후 구현 필요
        likeButton.setSelected(true)
//        likeButton.imageView.image = UIImage(named: "ic_photo_like_active")
        likeButton.userInteractionEnabled = false
        
        dislikeButton.setSelected(false)
//        dislikeButton.imageView.image = UIImage(named: "ic_photo_dislike_inactive")
        dislikeButton.userInteractionEnabled = true
    }
    
    private func setLikeButtonDisabled() {
        likeButton.setDisabled()
    }
    
    private func setDislikeButtonSelected() {
        likeButton.setSelected(false)
//        likeButton.imageView.image = UIImage(named: "ic_photo_like_inactive")
        likeButton.userInteractionEnabled = true
        
        dislikeButton.setSelected(true)
//        dislikeButton.imageView.image = UIImage(named: "ic_photo_dislike_active")
        dislikeButton.userInteractionEnabled = false
    }
    
    private func setDislikeButtonDisabled() {
        dislikeButton.setDisabled()
    }
    
    // TODO: 동현에게 두 버튼 액션 메서드 부분 이렇게 변경해놓고 viewWillDisappear()에서 처리하면 되는 것이 맞는지 물어보기
    final func likeButtonDidTap(sender: AnyObject) {
        setLikeButtonSelected()
        updatePhotoState(.Liked)
    }
    
    final func dislikeButtonDidTap(sender: AnyObject) {
        setDislikeButtonSelected()
        updatePhotoState(.Disliked)
    }
    
    private func updatePhotoState(photoState: PhotoState) {
        // TODO: 안드로이드 로직에 delegate 사용되는 곳이 없는데 동현에게 물어보기
        let photoStateUpdateRequest = PhotoStateUpdateRequest(photoId: photoId, state: photoState, delegate: nil)
        PhotoStateUpdater.instance.registerUpdateRequest(photoStateUpdateRequest)
        
        // TODO: 해당부분 동현과 얘기해서 처리하기(KVO 관련)
//        SwishDatabase.updatePhotoState(photoId, photoState: .Disliked)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
