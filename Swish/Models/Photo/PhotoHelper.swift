//
//  PhotoHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class PhotoHelper {
    
    static let invalidPhotoIndex = -1
    
    final class func findIndexOfPhotoWithPhotoId(photoId: Photo.ID, inPhotos photos: [Photo]) -> Int {
        return photos.indexOf { $0.id == photoId } ?? invalidPhotoIndex
    }
}
