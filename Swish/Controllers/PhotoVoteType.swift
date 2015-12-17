//
//  PhotoVoteType.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 16..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//
//  Usage:
//  PhotoActionType를 comfort하는 UIViewController 클래스의 viewDidLoad()에 setUpPhotoVoteView() 추가,
//  viewWillDisAppear()에 udpatePhotoState() 추가
//

import UIKit

protocol PhotoVoteType {
    var photo: Photo! { get }
    var photoVoteView: PhotoVoteView! { get }
}

extension PhotoVoteType where Self: UIViewController {
    
    final func setUpPhotoVoteView() {
        photoVoteView.setUpWithPhotoId(photo.id, withPhotoState: photo.photoState)
    }
    
    final func updatePhotoState() {
        PhotoStateUpdater.instance.execute()
    }
}
