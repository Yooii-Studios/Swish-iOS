//
//  PhotoActionType.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 3..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//
//  Usage:
//  PhotoActionType를 comfort하는 UIViewController 클래스의 viewDidLoad()에 setUpPhotoActionView()를 불러줄 것.
//  또한 viewWillAppear()에 refreshUnreadChatCount()을 불러줄 것
//
//  TODO: 로직 변경 - KVO를 사용하면 refreshUnreadChatCount()를 불러줄 필요가 없을 것 같아 우선 관련 로직 삭제. 추후 채팅 VC 구현 후
//  위 내용 확인하고 처리 및 주석 내용 변경할 것
//

import UIKit

protocol PhotoActionType {
    
    var photo: Photo! { get }
    var photoActionView: PhotoActionView! { get }
    
    func mapButtonDidTap(sender: AnyObject)
    func chatButtonDidTap(sender: AnyObject)
}

extension PhotoActionType where Self: UIViewController {
    
    final func setUpPhotoActionView() {
        setUpMapButton()
        setUpChatButton()
        observeUnreadCount()
        observePhotoStateForChatButtonVisibility()
    }
    
    private func observeUnreadCount() {
        PhotoObserver.observeUnreadMessageCountForPhoto(photo, owner: self) { [unowned self] (Int) -> Void in
            self.refreshUnreadChatCount()
        }
    }
    
    // TODO: showChatButtonWithAnimation(), hideChatButtonWithAnimation() 구현 필요
    private func observePhotoStateForChatButtonVisibility() {
        PhotoObserver.observePhotoStateForPhoto(photo, owner: self) { [unowned self] (id, state) -> Void in
            if state == .Liked {
                self.photoActionView.chatButton.alpha = 1
            } else {
                self.photoActionView.chatButton.alpha = 0
            }
        }
    }
    
    private func setUpMapButton() {
        if photo.photoState == .Delivered || photo.photoState == .Liked {
            photoActionView.mapButton.alpha = 1
        } else {
            photoActionView.mapButton.alpha = 0
        }
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: "mapButtonDidTap:")
        photoActionView.mapButton.addGestureRecognizer(singleTapGesture)
    }
    
    private func setUpChatButton() {
        if photo.photoState == .Liked {
            photoActionView.chatButton.alpha = 1
        } else {
            photoActionView.chatButton.alpha = 0
        }
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: "chatButtonDidTap:")
        photoActionView.chatButton.addGestureRecognizer(singleTapGesture)
    }
    
    private func showChatButtonWithAnimation() {
        print("showChatButtonWithAnimation")
    }
    
    private func hideChatButtonWithAnimation() {
        print("hideChatButtonWithAnimation")
    }
    
    // TODO: 동현에게 안드로이드 handleReceivedMessage에 로직을 어떻게 처리할 건지에 대해 물어보기
    private func refreshUnreadChatCount() {
         setUnreadChatCount(photo.unreadMessageCount)
    }
    
    private func setUnreadChatCount(count: Int) {
        if count > 0 && photoActionView.chatButton.alpha == 1 {
            photoActionView.unreadChatCountLabel.alpha = 1
            photoActionView.unreadChatCountLabel.text = String(count)
        } else {
            photoActionView.unreadChatCountLabel.alpha = 0
            photoActionView.unreadChatCountLabel.text = ""
        }
    }
    
    final func showMapViewController() {
        let storyboard = UIStoryboard(name: "PhotoMap", bundle: nil)
        let navigationViewController =
        storyboard.instantiateViewControllerWithIdentifier("PhotoMapNavController") as! UINavigationController
        
        let photoMapViewController = navigationViewController.topViewController as! PhotoMapViewController
        photoMapViewController.photoId = photo.id
        
        showViewController(navigationViewController, sender: self)
    }
    
    final func showChatDialog() {
        // TODO: 채팅쪽 UX 구현과 함께 구현 예정. Android의 ChatRoomOpener.start() 참고
        print("showChatDialog")
    }
}
