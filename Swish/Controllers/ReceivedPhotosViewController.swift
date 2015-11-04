//
//  ReceivedPhotosViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 3..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class ReceivedPhotosViewController: UIViewController {
    // TODO: 거리 레이블이 기준이 되어서 이 너비가 동적으로 정해진 다음, 이 것을 제외한 나머지 길이가 안드로이드의 match_parent + leftOf 조합처럼 활용할 수 있게 constraints 구성해볼 것. baseline은 유저 이름 레이블에 거리 레이블이 맞출 수 있게 할 것.
    
    private var receivedPhotos: Array<Photo>!
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receivedPhotos = SwishDatabase.receivedPhotos()
    }
}
