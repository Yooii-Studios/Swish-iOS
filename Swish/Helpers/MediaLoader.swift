//
//  MediaLoader.swift
//  Swish
//
//  Created by YunSeungyong on 2015. 9. 11..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import Foundation
import Photos

class MediaLoader {
    
    class func fetchPhotoAssets() -> PHFetchResult {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        return fetchResult
    }
    
    class func setAssetImageToImageView(asset: PHAsset, targetSize: CGSize, imageView: UIImageView) {
        let options = PHImageRequestOptions()
        options.version = PHImageRequestOptionsVersion.Current
        
        PHImageManager.defaultManager()
            .requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill,
                options: options, resultHandler: {(result, info) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        imageView.image = result
                    })
            })
    }
}