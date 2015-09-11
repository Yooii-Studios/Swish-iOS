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
    class func fetchDevicePhotoMedia() -> PHFetchResult {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        return fetchResult
    }
}