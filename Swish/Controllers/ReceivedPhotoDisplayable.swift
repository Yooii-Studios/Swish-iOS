//
//  ReceivedPhotoDisplayable.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

protocol ReceivedPhotoDisplayable: class {
    
    var currentDisplayingPhoto: Photo? { get set }
    var currentDisplayingPhotoIndex: Int? { get set }
    
    func displayPhoto(photo: Photo?)
}

extension ReceivedPhotoDisplayable where Self: UIViewController {
    
    private var receivedPhotos: Array<Photo> {
        get {
            return SwishDatabase.receivedPhotos()
        }
    }
    
    func initReceivedPhotoDisplayable() {
        if receivedPhotos.count > 0 {
            updateCurrentDisplayingPhotoWithIndex(0)
        }
        displayPhoto(currentDisplayingPhoto)
    }
    
    func refreshReceivedPhotoDisplayable() {
        if currentDisplayingPhotoIndex == nil && receivedPhotos.count > 0 {
            updateCurrentDisplayingPhotoWithIndex(0)
            displayPhoto(currentDisplayingPhoto)
        } else if let currentDisplayingPhoto = currentDisplayingPhoto where currentDisplayingPhoto.photoState == .Disliked {
            showNextPhoto()
        }
    }
    
    func showNextPhoto() {
        proceed()
        displayPhoto(currentDisplayingPhoto)
    }
    
//    private func initCurrentDisplayingPhoto() {
//        let receivedPhotos = self.receivedPhotos
//        if currentDisplayingPhotoIndex == nil && receivedPhotos.count > 0 {
//            updateCurrentDisplayingPhotoWithIndex(0)
//        }
//    }
    
    private func proceed() {
        let receivedPhotos = self.receivedPhotos
        guard let currentDisplayingPhotoIndex = currentDisplayingPhotoIndex where receivedPhotos.count > 0 else {
            invalidateCurrentDisplayingPhoto()
            return
        }
        let nextPhotoIndex = currentDisplayingPhotoIndex >= receivedPhotos.count - 1 ? 0 : currentDisplayingPhotoIndex + 1
        
        updateCurrentDisplayingPhotoWithIndex(nextPhotoIndex)
    }
    
    private func updateCurrentDisplayingPhotoWithIndex(index: Int) {
        currentDisplayingPhotoIndex = index
        currentDisplayingPhoto = receivedPhotos[index]
    }
    
    private func invalidateCurrentDisplayingPhoto() {
        currentDisplayingPhotoIndex = nil
        currentDisplayingPhoto = nil
    }
}
