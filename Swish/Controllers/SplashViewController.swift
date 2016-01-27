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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: 유저 등록 화면 구현 완료되면 해당 부분으로 아래 코드 옮긴 후 제거
        if !SwishDatabase.hasMe() {
            print("Registering Me to server...")
            MeManager.registerMe(onSuccess: { [weak self] me in
                print("Me registered. Now you can communicate with Swish server.")
                self?.showMain()
                })
        } else {
            print("Me already registered. You can communicate with Swish server.")
            showMain()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func showMain() {
        performSegueWithIdentifier(.ShowMain, sender: self)
    }
}
