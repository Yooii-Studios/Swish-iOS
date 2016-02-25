//
//  PhotoActionView.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 2..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable

@IBDesignable
class PhotoActionView: NibDesignable {
    
    @IBOutlet var mapButton: CircleButton!
    @IBOutlet var chatButton: CircleButton!
    @IBOutlet var unreadChatCountLabel: UILabel!
    
    // MARK: - Initialize
    
    final func setUpWithPhoto(photo: Photo) {
        setUpMapButtonWithPhotoState(photo.photoState)
        setUpChatButtonWithPhotoState(photo.photoState)
        observeUnreadCountForUpdatingLabel(photo)
        observePhotoStateForVisibility(photo)
    }
    
    final func refreshWithPhotoState(photoState: PhotoState) {
        setUpMapButtonWithPhotoState(photoState)
        setUpChatButtonWithPhotoState(photoState)
    }
    
    private func setUpMapButtonWithPhotoState(photoState: PhotoState) {
        if photoState == .Delivered || photoState == .Liked {
            mapButton.alpha = 1
        } else {
            mapButton.alpha = 0
        }
    }
    
    private func setUpChatButtonWithPhotoState(photoState: PhotoState) {
        if photoState == .Liked {
            chatButton.alpha = 1
        } else {
            chatButton.alpha = 0
        }
    }
    
    private func observeUnreadCountForUpdatingLabel(photo: Photo) {
        PhotoObserver.observeUnreadMessageCountForPhoto(photo, owner: self) { [weak self] unreadMessageCount in
            self?.setUnreadMessageCount(unreadMessageCount)
        }
    }
    
    // TODO: 맵, 챗 버튼 관련 애니메이션 추가 구현 필요
    private func observePhotoStateForVisibility(photo: Photo) {
        PhotoObserver.observePhotoStateForPhoto(photo, owner: self) { [weak self] _, state in
            if state == .Liked {
                if self?.mapButton.alpha == 0 {
                    self?.showMapButtonWithAnimation()
                }
                self?.showChatButtonWithAnimation()
            } else if state == .Delivered {
                self?.showMapButtonWithAnimation()
            } else {
                if photo.isSentPhoto {
                    self?.hideMapButtonWithAnimation()
                }
                self?.hideChatButtonWithAnimation()
            }
        }
    }
    
    // TODO: 네 애니메이션 메서드 추후 보강 구현 필요
    private func showMapButtonWithAnimation() {
        mapButton.alpha = 1
    }
    
    private func hideMapButtonWithAnimation() {
        mapButton.alpha = 0
    }
    
    private func showChatButtonWithAnimation() {
        print("showChatButtonWithAnimation")
        chatButton.alpha = 1    }
    
    private func hideChatButtonWithAnimation() {
        print("hideChatButtonWithAnimation")
        chatButton.alpha = 0
    }
    
    // TODO: 동현에게 안드로이드 handleReceivedMessage에 로직을 어떻게 처리할 건지에 대해 물어보기
    
    private func setUnreadMessageCount(count: Int) {
        if count > 0 && chatButton.alpha == 1 {
            unreadChatCountLabel.alpha = 1
            unreadChatCountLabel.text = String(count)
        } else {
            unreadChatCountLabel.alpha = 0
            unreadChatCountLabel.text = ""
        }
    }
}
