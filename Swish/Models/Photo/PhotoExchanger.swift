//
//  PhotoExchanger.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 28..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class PhotoExchanger {
    
    typealias SendCompletion = () -> Void
    typealias ReceiveCompletion = (photos: [Photo]?) -> Void
    
    final class func exchange(photo: Photo, image: UIImage,
        sendCompletion: SendCompletion, receiveCompletion: ReceiveCompletion) {
            let photoSendRequest = createPhotoSendRequest(photo, image: image, completion: { sentPhotoCount in
                sendCompletion()
                guard sentPhotoCount > 0 else {
                    receiveCompletion(photos: nil)
                    return
                }
                let photoReceiveRequest = createPhotoReceiveRequest(sentPhotoCount,
                    departLocation: photo.departLocation, completion: receiveCompletion)
                PhotoReceiver.execute(photoReceiveRequest)
            })
            PhotoSender.execute(photoSendRequest)
    }
    
    private final class func createPhotoSendRequest(photo: Photo, image: UIImage,
        completion: (sentPhotoCount: Int) -> Void) -> PhotoSendRequest {
        return PhotoSendRequest(photos: [photo], images: [image],
            onSendPhotoCallback: { photoSendState in
                // Ignored: iOS 초기 버전의 최대 전송 사진 갯수가 1개 이므로 따로 UI업데이트가 필요하지 않다고 판단
            }, onSendAllPhotosCallback: { sentPhotoCount in
                completion(sentPhotoCount: sentPhotoCount)
        })
    }
    
    private final class func createPhotoReceiveRequest(sentPhotoCount: Int, departLocation: CLLocation,
        completion: ReceiveCompletion) -> PhotoReceiveRequest {
            return PhotoReceiveRequest(requestCount: sentPhotoCount, currentLocation: departLocation,
                onReceiveAllPhotosCallback: { (photos) -> Void in
                    completion(photos: photos)
                }, onReceivePhotoCallback: { (state) -> Void in
                    // Ignored: iOS 초기 버전의 최대 전송 사진 갯수가 1개 이므로 따로 UI업데이트가 필요하지 않다고 판단
                }, onFailCallback: { () -> Void in
                    completion(photos: nil)
            })
    }
}
