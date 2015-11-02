//
//  ShareResultController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 10. 20..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class ShareResultViewController: UIViewController {

    @IBOutlet weak var testImageView: UIImageView!
    final var receivedPhoto: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotoImageHelper.imageWithPhoto(receivedPhoto) { image in
            self.testImageView?.image = image
        }
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
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
