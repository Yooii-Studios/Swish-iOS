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
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
