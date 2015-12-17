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

import UIKit

protocol PhotoActionType {
    
    var photo: Photo! { get }
    var photoActionView: PhotoActionView! { get }
    
    func mapButtonDidTap(sender: AnyObject)
    func chatButtonDidTap(sender: AnyObject)
}

extension PhotoActionType where Self: UIViewController {
    
    final func setUpPhotoActionView() {
        initUnreadCountReactStream()
        setUpMapButton()
        setUpChatButton()
    }
    
    private func initUnreadCountReactStream() {
        // TODO: React Stream으로 사진의 카운트가 변경될 때 숫자를 변경해주게 구현
        // 숫자가 0이라면 invisible, 있을 경우 visible과 숫자 변경
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
        
        // TODO: 사진이 Like나 Dislike상태이면 상태 변경 불가능하게 처리
        // 이 부분은 받은 사진과 연관이 있는 부분이고, PhotoVoteType을 만들어서 연계해서 처리해야 할 듯
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: "chatButtonDidTap:")
        photoActionView.chatButton.addGestureRecognizer(singleTapGesture)
    }
    
    // TODO: photoState의 상태를 React로 KVO 처리해서 showChatButtonWithAnimation(), hideChatButtonWithAnimation() 구현 필요
    private func initChatButtonReactStream() {
        
    }
    
    private func showChatButtonWithAnimation() {
        print("showChatButtonWithAnimation")
    }
    
    private func hideChatButtonWithAnimation() {
        print("hideChatButtonWithAnimation")
    }
    
    // TODO: 동현에게 안드로이드 handleReceivedMessage에 로직을 어떻게 처리할 건지에 대해 물어보기
    final func refreshUnreadChatCount() {
         setUnreadChatCount(photo.unreadMessageCount)
    }
    
    private func setUnreadChatCount(count: Int) {
        if count <= 0 {
            photoActionView.unreadChatCountLabel.alpha = 0
            photoActionView.unreadChatCountLabel.text = ""
        } else {
            photoActionView.unreadChatCountLabel.alpha = 1
            photoActionView.unreadChatCountLabel.text = String(count)
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
        // TODO: 채팅쪽 UX 구현과 함께 구현 예정
        print("showChatDialog")
    }
}
