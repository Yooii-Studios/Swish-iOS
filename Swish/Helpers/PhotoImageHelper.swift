//
//  PhotoImageHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 20..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

final class PhotoImageHelper {
    
    typealias OnSaveImageCallback = (fileName: String) -> Void
    
    private static let cache = NSCache()
    
    final class func imageWithPhoto(photo: Photo, onSuccess: (image: UIImage?) -> ()) {
        if let image = cache.objectForKey(photo.fileName) as? UIImage {
            onSuccess(image: image)
            return
        }
        let path = FileHelper.filePathWithName(photo.fileName, inDirectory: SubDirectory.Photos)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            let image = UIImage(contentsOfFile: path)
            
            if let image = image {
                cache.setObject(image, forKey: photo.fileName)
            }
            dispatch_async(dispatch_get_main_queue(), {
                onSuccess(image: image)
            })
        })
    }
    
    final class func saveImage(image: UIImage, onSuccess: OnSaveImageCallback) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let fileName = "\(NSDate().timeIntervalSince1970)"
            let imagePath = FileHelper.filePathWithName(fileName, inDirectory: SubDirectory.Photos)
            ImageHelper.saveImage(image, intoPath: imagePath)
            cache.setObject(image, forKey: fileName)
            
            dispatch_async(dispatch_get_main_queue(), {
                onSuccess(fileName: fileName)
            })
        }
    }
}
