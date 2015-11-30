//
//  PhotoReceiver.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 20..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Alamofire
import AlamofireImage

// TODO: Possible refactor(see PhotoSender)
final class PhotoReceiver {
    
    private enum Result {
        
        case Success, Failure
        
        func isSuccess() -> Bool {
            return self == .Success
        }
    }
    
    private var state: PhotoReceiveState!
    private let request: PhotoReceiveRequest
    private var resultPhotos:Array<Photo!>!
    
    private init(request: PhotoReceiveRequest) {
        self.request = request
    }
    
    class func execute(request: PhotoReceiveRequest) {
        PhotoReceiver(request: request).execute()
    }
    
    private func execute() {
        FileHelper.createPhotosDirectory()
        
        let senderId = MeManager.me().id
        PhotoServer.photoResponsesWith(senderId, departLocation: request.currentLocation, photoCount: request.requestCount,
            onSuccess: { (photoResponses) -> () in
                self.savePhotosAndNotify(photoResponses)
            }) { (error) -> () in
                    print(error)
                self.request.onFailCallback()
        }
    }
    
    private func savePhotosAndNotify(photoResponses: [PhotoResponse]) {
        let count = photoResponses.count
        state = PhotoReceiveState(totalCount: count)
        resultPhotos = Array<Photo!>(count: count, repeatedValue: nil)
        
        if count > 0 {
            downloadImagesAndNotify(count, withPhotoResponses: photoResponses)
        } else {
            self.request.onFailCallback()
        }
    }
    
    private func downloadImagesAndNotify(count: Int, withPhotoResponses photoResponses: [PhotoResponse]) {
        for index in 0...count-1 {
            let photoResponse = photoResponses[index]
            let imageUrl = photoResponse.imageUrl
            PhotoReceiver.downloadAndSaveImage(photoResponse.photo, imageUrl: imageUrl, onSaveImageCallback: {
                SwishDatabase.saveOtherUser(photoResponse.user)
                photoResponse.photo.arrivedLocation = self.request.currentLocation
                SwishDatabase.saveReceivedPhoto(photoResponse.user, photo: photoResponse.photo)
                
                self.resultPhotos[index] = photoResponse.photo
                
                self.notifySuccess()
                }, onFail: { () -> Void in
                    self.notifyFailure()
            })
        }
    }
    
    private class func downloadAndSaveImage(photo: Photo, imageUrl: String,
        onSaveImageCallback: () -> Void, onFail: () -> Void) {
            Alamofire.request(.GET, imageUrl).responseImage { response in
                if let image = response.result.value {
                    photo.saveImage(image, handler: onSaveImageCallback)
                } else {
                    onFail()
                }
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
        request.onReceivePhotoCallback(state: state)
        if state.done {
            var photos = Array<Photo>()
            for photo in resultPhotos {
                if let photo = photo {
                    photos.append(photo)
                }
            }
            request.onReceiveAllPhotosCallback(photos: photos)
        }
    }
}

struct PhotoReceiveRequest {
    
    typealias OnReceiveAllPhotosCallback = (photos: [Photo]) -> Void
    typealias OnReceivePhotoCallback = (state: PhotoReceiveState) -> Void
    typealias OnFailCallback = () -> Void
    
    let requestCount: Int
    let currentLocation: CLLocation
    let onReceiveAllPhotosCallback: OnReceiveAllPhotosCallback
    let onReceivePhotoCallback: OnReceivePhotoCallback
    let onFailCallback: OnFailCallback
    
    init(requestCount: Int, currentLocation: CLLocation, onReceiveAllPhotosCallback: OnReceiveAllPhotosCallback,
        onReceivePhotoCallback: OnReceivePhotoCallback, onFailCallback: OnFailCallback) {
            self.requestCount = requestCount
            self.currentLocation = currentLocation
            self.onReceiveAllPhotosCallback = onReceiveAllPhotosCallback
            self.onReceivePhotoCallback = onReceivePhotoCallback
            self.onFailCallback = onFailCallback
    }
}

struct PhotoReceiveState {
    
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
