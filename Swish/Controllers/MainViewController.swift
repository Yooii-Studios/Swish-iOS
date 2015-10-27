//
//  ViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import SnapKit
import CTAssetsPickerController

class MainViewController: UIViewController, UINavigationControllerDelegate, CTAssetsPickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // FIXME: 메서드 이름 변경하고 Photo Trends가 될 예정
    @IBAction func cameraButtonDidTap(sender: UIButton!) {
        /*
        NSLog("cameraButtonDidTap")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            imagePickerController.allowsEditing = false
            showViewController(imagePickerController, sender: self)
        } else {
            NSLog("cameraNotAvailable")
        }
        */
    }
    
    @IBAction func pickPhotoButtonDidTap(sender: UIButton!) {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
            if status == PHAuthorizationStatus.Authorized {
                dispatch_async(dispatch_get_main_queue()) {
                    // init
                    let picker = CTAssetsPickerController()
                    picker.delegate = self
                    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Delegate Function
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        guard assets.count > 0, let asset: PHAsset! = (assets as! [PHAsset])[0] else  {
            picker.dismissViewControllerAnimated(true, completion: nil)
            return
        }
    
        let options = PHImageRequestOptions()
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize.init(width: 320, height: 320), contentMode: .AspectFill, options: options) { image, info in
            // TODO: 사진을 안드로이드에서 처럼 정해진 사이즈로, 1:1로 자르고 넘겨 주어야 할 듯
            picker.dismissViewControllerAnimated(false, completion: nil)
            self.showDressingViewContoller(image)
        }
    }
    
    func showDressingViewContoller(image: UIImage?) {
        let storyboard = UIStoryboard(name: "Dressing", bundle: nil)
        let navigationViewController =
        storyboard.instantiateViewControllerWithIdentifier("dressingNaviViewController") as! UINavigationController
        let dressingViewController = navigationViewController.topViewController as! DressingViewController
        dressingViewController.image = image
        
        // TODO: whose view is not in the window hierarchy! 문제 해결 필요
        // 둘 중 한 가지 방식으로 해결해야 할 듯
        showViewController(navigationViewController, sender: self)
//        presentViewController(navigationViewController, animated: true, completion: nil)
    }
    
    @IBAction func unwindFromDressingViewController(segue: UIStoryboardSegue) {
        print("unwindFromDressingViewController")
    }
}
