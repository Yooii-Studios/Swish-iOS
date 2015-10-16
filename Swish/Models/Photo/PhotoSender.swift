//
//  PhotoSender.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 16..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

final class PhotoSender {
    private enum Result {
        case Success, Failure
        
        func isSuccess() -> Bool {
            return self == .Success
        }
    }
    
    private let state: PhotoSendState
    private let request: PhotoSendRequest
    
    private init(request: PhotoSendRequest) {
        self.request = request
        self.state = PhotoSendState(totalCount: request.photos.count)
    }
    
    // let images = [ UIImage(contentsOfFile: filePathOne)!, UIImage(contentsOfFile: filePathTwo)! ]
    // ImageHelper.clearAndSaveTempImages(images)
    //
    class func execute(request: PhotoSendRequest) {
        PhotoSender(request: request).execute()
    }
    
    private func execute() {
        let tempFileNames = ImageHelper.clearAndSaveTempImages(request.images)
        
        let senderId = MeManager.me().id
        var index = 0
        for photo in request.photos {
            photo.fileName = tempFileNames[index]
            PhotoServer.save(photo, userId: senderId, onSuccess: { (id) -> () in
                let newFileName = ImageHelper.moveTempImageToPhotosDirectory(photo.fileName)
                SwishDatabase.saveSentPhoto(photo, serverId: id, newFileName: newFileName)
                
                self.notifySuccess()
                if self.state.done {
                    FileHelper.clearTempPhotosFileDirectory()
                }
                }, onFail: { (error) -> () in
                    self.notifyFailure()
            })
            index++
        }
    }
    
    private func notifySuccess() {
        notifyResult(.Success)
    }
    
    private func notifyFailure() {
        notifyResult(.Failure)
    }
    
    private func notifyResult(result: Result) {
        updateState(result)
        notifyCallbacks()
    }
    
    private func updateState(result: Result) {
        result.isSuccess() ? ++state.succeedCount : ++state.failedCount
    }
    
    private func notifyCallbacks() {
        request.onSendPhotoCallback(photoSendState: state)
        if state.done {
            request.onSendAllPhotosCallback(sentPhotoCount: state.succeedCount)
        }
    }
}

final class PhotoSendRequest {
    typealias OnSendPhotoCallback = (photoSendState: PhotoSendState) -> ()
    typealias OnSendAllPhotosCallback = (sentPhotoCount: Int) -> ()
    
    let photos: [Photo]
    let images: [UIImage]
    let onSendPhotoCallback: OnSendPhotoCallback
    let onSendAllPhotosCallback: OnSendAllPhotosCallback
    
    init(photos: [Photo], images: [UIImage], onSendPhotoCallback: OnSendPhotoCallback,
        onSendAllPhotosCallback: OnSendAllPhotosCallback) {
            // TODO: check photos.count == images.count
            self.photos = photos
            self.images = images
            self.onSendPhotoCallback = onSendPhotoCallback
            self.onSendAllPhotosCallback = onSendAllPhotosCallback
    }
}

final class PhotoSendState {
    var succeedCount: Int = 0
    var failedCount: Int = 0
    let totalCount: Int
    var done: Bool {
        return succeedCount + failedCount >= totalCount
    }
    
    init(totalCount: Int) {
        self.totalCount = totalCount
    }
}
