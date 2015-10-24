//
//  DressingViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 11..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit

class DressingViewController: UIViewController, SegueHandlerType {
    
    // MARK: SegueHandlerType
    
    enum SegueIdentifier: String {
        case ShowShareResult
    }
    
    var testImage : UIImage?
    
    @IBOutlet var testImageView : UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if testImage != nil {
            testImageView?.image = testImage
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonDidTap(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueIdentifier = segueIdentifierForSegue(segue)
        
        switch segueIdentifier {
            case .ShowShareResult:
            // TODO: 여기서부터 초기화는 동현이 추후에 해줄 것
            //            let destinationController = segue.destinationViewController as! ShareResultController
            //            destinationController.image = image
            print("showShareResult")
        }
    }

    @IBAction func shareButtonDidTap(sender: AnyObject) {
        // TODO: 나중에 사진 보내기 애니메이션 구현할 것
        
        // 애니메이션 없이 동현이 사진 보내기 로직을 구현하고, 
        // 콜백에서 여기에 미리 만들어둔 ShareResultViewController
        // 와의 연결 로직을 옮겨 준다.
        performSegueWithIdentifier(.ShowShareResult, sender: self)
    }
    
    
}
