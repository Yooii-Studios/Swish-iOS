//
//  PhotoActionView.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 2..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable

class PhotoActionView: NibDesignable {
    
    @IBOutlet var mapButton: CircleButton!
    @IBOutlet var chatButton: CircleButton!
    @IBOutlet var unreadChatCountLabel: UILabel!
    
    // TODO: 추후 UI작업을 하면서 필요할 때 다시 사용할지 몰라 주석처리
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    /*
    override func prepareForInterfaceBuilder() {
        
    }
    */
}
