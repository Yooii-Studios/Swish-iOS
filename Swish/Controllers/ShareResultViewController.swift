//
//  ShareResultController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 10. 20..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class ShareResultViewController: UIViewController, SegueHandlerType {

    @IBOutlet weak var testImageView: UIImageView!
    
    // MARK: SegueHandlerType
    
    enum SegueIdentifier: String {
        case UnwindFromShareResultToMain
    }
    
    final var receivedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segueIdentifierForSegue(segue) {
        case .UnwindFromShareResultToMain:
            // TODO: 돌아가기 전 필요한 처리가 있다면 해줄 것
            // FIXME: 완벽하게 unwind가 안되고 Dressing이 보이면서 unwind 되는 현상 해결 필요
            print("prepareForSegue: UnwindFromShareResultToMain")
            
        }
    }
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
