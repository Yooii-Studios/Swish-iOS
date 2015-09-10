//
//  ViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var pickPhotosButton: UIButton!
    @IBOutlet weak var myInfoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cameraButtonDidTap(sender: UIButton!) {
    }
    
    /*
    @IBAction func pickPhotosButtonDidTap(sender: UIButton!) {
        let photoPickerViewController = PhotoPickerViewController()
        showViewController(photoPickerViewController, sender: self)
    }
    
    @IBAction func myInfoButtonDidTap(sender: UIButton!) {
        let myInfoViewController = MyInfoViewController()
        showViewController(myInfoViewController, sender: self)
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
