//
//  ReceivedPhotoDisplayable.swift
//   Usage:
//    1. ReceivedPhotoDisplayable protocol을 conform하도록 아래 요구사항 구현
//      var currentDisplayingPhoto: Photo? { get set }
//      var currentDisplayingPhotoIndex: Int? { get set }
//
//      func displayReceivedPhoto(photo: Photo?)
//
//      ** currentDisplayingPhoto, currentDisplayingPhotoIndex는 선언만 하고 초기화 필요 없음.
//
//    2. viewDidLoad에서 initReceivedPhotoDisplayable() 호출, viewWillAppear에서 refreshReceivedPhotoDisplayable() 호출
//    ex)
//      override func viewDidLoad() {
//          super.viewDidLoad()
//
//          initReceivedPhotoDisplayable()
//      }
//
//      override func viewWillAppear(animated: Bool) {
//          super.viewWillAppear(animated)
//
//          refreshReceivedPhotoDisplayable()
//      }
//
//    3. func displayReceivedPhoto(photo: Photo?) 구현
//    ex)
//      final func displayReceivedPhoto(photo: Photo?) {
//          if let photo = photo {
//              /* 사진 표시 */
//          } else {
//              /* 사진이 없는 경우 기본 세팅(환영 메시지) 표시 */
//          }
//      }
//
//  Swish
//
//  Created by 정동현 on 2015. 12. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

protocol ReceivedPhotoDisplayable: class {
    
    var currentDisplayingPhoto: Photo? { get set }
    var currentDisplayingPhotoIndex: Int? { get set }
    
    func displayReceivedPhoto(photo: Photo?)
}

extension ReceivedPhotoDisplayable where Self: UIViewController {
    
    private var receivedPhotos: Array<Photo> {
        return SwishDatabase.receivedPhotos()
    }
    private var hasReceivedPhoto: Bool {
        return receivedPhotos.count > 0
    }
    
    func initReceivedPhotoDisplayable() {
        initCurrentDisplayingPhotoWithIndex()
        showCurrentPhoto()
    }
    
    func refreshReceivedPhotoDisplayable() {
        if currentDisplayingPhotoIndex == nil && hasReceivedPhoto {
            initReceivedPhotoDisplayable()
        } else if let currentDisplayingPhoto = currentDisplayingPhoto
            where currentDisplayingPhoto.photoState == .Disliked {
                showNextPhoto()
        }
    }
    
    func showCurrentPhoto() {
        displayReceivedPhoto(currentDisplayingPhoto)
    }
    
    func showNextPhoto() {
        proceedToNextPhoto()
        displayReceivedPhoto(currentDisplayingPhoto)
    }
    
    private func proceedToNextPhoto() {
        let receivedPhotos = self.receivedPhotos
        guard let currentDisplayingPhotoIndex = currentDisplayingPhotoIndex where receivedPhotos.count > 0 else {
            invalidateCurrentDisplayingPhoto()
            return
        }
        let nextPhotoIndex = currentDisplayingPhotoIndex >= receivedPhotos.count - 1
            ? 0 : currentDisplayingPhotoIndex + 1
        
        updateCurrentDisplayingPhotoWithIndex(nextPhotoIndex)
    }
    
    private func initCurrentDisplayingPhotoWithIndex() {
        if hasReceivedPhoto {
            updateCurrentDisplayingPhotoWithIndex(0)
        }
    }
    
    private func invalidateCurrentDisplayingPhoto() {
        updateCurrentDisplayingPhotoWithIndex(nil)
    }
    
    private func updateCurrentDisplayingPhotoWithIndex(index: Int?) {
        currentDisplayingPhotoIndex = index
        currentDisplayingPhoto = index != nil ? receivedPhotos[index!] : nil
    }
}
