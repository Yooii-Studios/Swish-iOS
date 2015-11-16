//
//  MyInfoViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit

class MyInfoViewController: UITabBarController {
   
    enum TabType: Int {
        case Received
        case Sent
        case Profile
    }
    
    var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelBarButtonDidTap() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        // TODO: 로컬라이징 필요
        if let currentTabType = TabType(rawValue: selectedIndex) {
            switch currentTabType {
            case .Received:
                title = "RECEIVED"
            case .Sent:
                title = "SENT"
            case .Profile:
                title = "PROFILE"
            }
        }
    }
}
