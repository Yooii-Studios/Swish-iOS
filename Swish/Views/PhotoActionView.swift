//
//  PhotoActionView.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 2..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable

@IBDesignable
class PhotoActionView: NibDesignable {
    
    @IBOutlet var mapButton: CircleButton!
    @IBOutlet var chatButton: CircleButton!
    @IBOutlet var unreadChatCountLabel: UILabel!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func prepareForInterfaceBuilder() {
        
    }
}
