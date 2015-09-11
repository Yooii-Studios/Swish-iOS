//
//  ViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cameraButtonDidTap(sender: UIButton!) {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Delegate Function
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        NSLog("cameraDidFinishPickingImage")
        let storyboard = UIStoryboard(name: "Dressing", bundle: nil)
        
        let navigationViewController = storyboard.instantiateViewControllerWithIdentifier("dressingNaviViewController") as! UINavigationController
        
        let dressingViewController = navigationViewController.topViewController as! DressingViewController
        
//        let dressingViewController = storyboard.instantiateViewControllerWithIdentifier("dressingViewController") as! DressingViewController
        
        dressingViewController.testImage = image
        
        picker.showViewController(navigationViewController, sender: self)
    }
}
