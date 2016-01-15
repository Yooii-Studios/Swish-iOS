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
}

extension PhotoActionType where Self: UIViewController {
    
    final func setUpPhotoActionView() {
        photoActionView.setUpWithPhoto(photo)
        initButtonGestures()
    }
    
    private func initButtonGestures() {
        photoActionView.mapButton.tapped { _ in
            self.showMapViewController()
        }
        
        photoActionView.chatButton.tapped { _ in
            self.showChatDialog()
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
    
    // TODO: 이름 변경하기. 안드로이드와 ChatRoomOpener 클래스를 똑같이 만드는 방법 or extension에 직접 구현을 고민하기
    final func showChatDialog() {
        // TODO: 채팅쪽 UX 구현과 함께 구현 예정. Android의 ChatRoomOpener.start() 참고
        print("showChatDialog")
    }
}
