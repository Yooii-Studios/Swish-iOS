//
//  PhotoPickable.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 10. 28..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import CTAssetsPickerController

class PhotoPickerDelegateHandler: NSObject, CTAssetsPickerControllerDelegate {
    
    typealias Completion = (image: UIImage) -> Void
    
    var completion: Completion
    
    init(completion: Completion) {
        self.completion = completion
    }
    
    // MARK: - Delegate Function
    
    @objc final func assetsPickerController(picker: CTAssetsPickerController!, shouldSelectAsset asset: PHAsset!) -> Bool {
        return picker.selectedAssets.count < 1
    }
    
    @objc final func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        guard assets.count > 0, let asset: PHAsset! = (assets as! [PHAsset])[0] else  {
            picker.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        let options = PHImageRequestOptions()
        
        // TODO: 사진을 안드로이드에서 처럼 정해진 사이즈로, 1:1로 자르고 넘겨 주어야 할 듯
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize.init(width: 640, height: 640), contentMode: .AspectFill, options: options) { image, info in
            picker.dismissViewControllerAnimated(false, completion: nil)
            if let image = image {
                self.completion(image: image)
            }
        }
    }
}

@objc protocol PhotoPickable {
    var photoPickerDelegate: PhotoPickerDelegateHandler? { get }

//    func photoPickerDidPickImage(image: UIImage)
}

extension PhotoPickable where Self: UIViewController {
    
    final func showPhotoPickerContoller() {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
            if status == PHAuthorizationStatus.Authorized {
                dispatch_async(dispatch_get_main_queue()) {
                    // init
                    let picker = CTAssetsPickerController()
                    picker.delegate = self.photoPickerDelegate
                    
                    // set default album (Camera Roll)
                    picker.defaultAssetCollection = PHAssetCollectionSubtype.SmartAlbumUserLibrary
                    
                    // create options for fetching photo only
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
                    
                    // assign options
                    picker.assetsFetchOptions = fetchOptions
                    
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
                        picker.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                    }
                    
                    self.showViewController(picker, sender: self)
                }
            }
        }
    }
}
