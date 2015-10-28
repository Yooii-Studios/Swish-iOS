//
//  PhotoExchanger.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 28..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class PhotoExchanger {
    
    typealias Completion = (photos: [Photo]?) -> Void
    private typealias SendPhotoCompletion = (sentPhotoCount: Int) -> Void
    
    final class func exchange(photo: Photo, image: UIImage, departLocation: CLLocation, completion: Completion) {
        let photoSendRequest = createPhotoSendRequest(photo, image: image, completion: { sentPhotoCount in
            guard sentPhotoCount > 0 else {
                completion(photos: nil)
                return
            }
            let photoReceiveRequest = createPhotoReceiveRequest(sentPhotoCount, departLocation: departLocation,
                completion: completion)
            PhotoReceiver.execute(photoReceiveRequest)
        })
        PhotoSender.execute(photoSendRequest)
    }
    
    private final class func createPhotoSendRequest(photo: Photo, image: UIImage,
        completion: SendPhotoCompletion) -> PhotoSendRequest {
        return PhotoSendRequest(photos: [photo], images: [image],
            onSendPhotoCallback: { photoSendState in
                // Ignored: iOS 초기 버전의 최대 전송 사진 갯수가 1개 이므로 따로 UI업데이트가 필요하지 않다고 판단
            }, onSendAllPhotosCallback: { sentPhotoCount in
                completion(sentPhotoCount: sentPhotoCount)
        })
    }
    
    private final class func createPhotoReceiveRequest(sentPhotoCount: Int, departLocation: CLLocation,
        completion: Completion) -> PhotoReceiveRequest {
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
