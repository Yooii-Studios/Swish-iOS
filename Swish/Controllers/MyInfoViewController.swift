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

        initViewControllers()
        selectTab(0)
    }
    
    private func initViewControllers() {
        let receivedPhotoStoryboard = UIStoryboard(name: "ReceivedPhoto", bundle: nil)
        let sentPhotoStoryboard = UIStoryboard(name: "SentPhoto", bundle: nil)
        let myProfileStoryboard = UIStoryboard(name: "MyProfile", bundle: nil)
        
        guard let receivedPhotoCollectionVC = receivedPhotoStoryboard.instantiateInitialViewController() else {
            return
        }
        guard let sentPhotoCollectionVC = sentPhotoStoryboard.instantiateInitialViewController() else {
            return
        }
        guard let myProfileVC = myProfileStoryboard.instantiateInitialViewController() else {
            return
        }
        
        viewControllers = [receivedPhotoCollectionVC, sentPhotoCollectionVC, myProfileVC]
    }
    
    private func selectTab(index: Int) {
        selectedIndex = 0
        let tabItem = tabBar.items![selectedIndex]
        tabBar(tabBar, didSelectItem: tabItem)
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
        guard let newIndex = tabBar.items?.indexOf(item), let currentTabType = TabType(rawValue: newIndex) else {
            return
        }
        
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
