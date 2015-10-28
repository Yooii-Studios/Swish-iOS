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

class MainViewController: UIViewController, UINavigationControllerDelegate, PhotoPickable {

    var photoPickerDelegate: PhotoPickerDelegateHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoPickerDelegate = PhotoPickerDelegateHandler() {
            self.showDressingViewContoller($0)
        }
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
        showPhotoPickerContoller()
    }
    
    @IBAction func unwindFromDressingViewController(segue: UIStoryboardSegue) {
        print("unwindFromDressingViewController")
    }
    
    func showDressingViewContoller(image: UIImage) {
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
}
