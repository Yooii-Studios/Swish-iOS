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
    var cameraButton: UIButton!
    var pickPhotosButton: UIButton!
    var myInfoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initButtons()
    }
    
    func initButtons() {
        pickPhotosButton = UIButton()
        pickPhotosButton.setTitle("Pick photos", forState: .Normal)
        pickPhotosButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        pickPhotosButton.setTitleColor(UIColor.blueColor(), forState: .Highlighted)
        pickPhotosButton.addTarget(self, action: "pickPhotosButtonDidTap:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(pickPhotosButton)
        pickPhotosButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-50)
            make.centerX.equalTo(self.view)
        }
        
        cameraButton = UIButton()
        cameraButton.setTitle("Camera", forState: .Normal)
        cameraButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cameraButton.setTitleColor(UIColor.blueColor(), forState: .Highlighted)
        cameraButton.addTarget(self, action: "cameraButtonDidTap:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cameraButton)
        cameraButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(pickPhotosButton.snp_left).offset(-30)
            make.bottom.equalTo(pickPhotosButton.snp_bottom)
        }
        
        myInfoButton = UIButton()
        myInfoButton.setTitle("My Info", forState: .Normal)
        myInfoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        myInfoButton.setTitleColor(UIColor.blueColor(), forState: .Highlighted)
        myInfoButton.addTarget(self, action: "myInfoButtonDidTap:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(myInfoButton)
        myInfoButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(pickPhotosButton.snp_right).offset(30)
            make.bottom.equalTo(pickPhotosButton.snp_bottom)
        }
    }

    func cameraButtonDidTap(sender: UIButton!) {
        NSLog("cameraButtonDidTap")
    }
    
    func pickPhotosButtonDidTap(sender: UIButton!) {
        NSLog("pickPhotosButtonDidTap")
    }
    
    func myInfoButtonDidTap(sender: UIButton!) {
        NSLog("myInfoButtonDidTap")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
