//
//  PhotoPickerViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit

class PhotoPickerViewController: UIViewController {
    
    var dismissButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        initDismissButton()
    }

    func initDismissButton() {
        dismissButton = UIButton()
        dismissButton.setTitle("Dismiss", forState: .Normal)
        dismissButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        dismissButton.setTitleColor(UIColor.blueColor(), forState: .Highlighted)
        dismissButton.addTarget(self, action: "dismissButtonDidTap:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(dismissButton)
        dismissButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-50)
            make.centerX.equalTo(self.view)
        }
    }
    
    func dismissButtonDidTap(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
