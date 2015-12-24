//
//  SplashViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, SegueHandlerType {

    enum SegueIdentifier: String {
        case ShowMain
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: 안드로이드 UserManager.hasValidUser()와 같은 로직 필요
        
        // 등록하지 않았을 경우 아래 로직으로
        
        // TODO: 유저 등록 관련은 추후 Intro로 옮겨질 로직이지만 동현이 원하는 동작 아래 부분에 우선 구현해둘 것
        // 구현 이후 '추후 Intro로 로직 옮길 것' 주석을 남겨둘 것
        // dispatch는 임시로 달아둔 것이고, 구현될 로직에 콜백이나 delegate가 있다면 그곳에서 perform을 해주면 될 듯
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(.ShowMain, sender: self)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
