//
//  ChatIndicatorView.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 22..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable
import SwiftyColor

@IBDesignable
class ChatIndicatorView: NibDesignable {
    
    @IBOutlet weak var chatCountLabel: UILabel!
    @IBOutlet weak var iconTrailingConstraints: NSLayoutConstraint!
    @IBOutlet weak var labelTrailingConstraints: NSLayoutConstraint!
    
    func initWithPhoto(photo: Photo) {
        backgroundColor = 0x000000 ~ 29% // 4C
        
        if photo.hasOpenedChatRoom {
            alpha = 1
            
            // TODO: 채팅방은 열려있는 채 채팅이 있거나 없을 경우 constraints 처리가 필요
            if photo.unreadMessageCount > 0 {
                chatCountLabel.alpha = 1
                chatCountLabel.text = String(photo.unreadMessageCount)
                labelTrailingConstraints.active = true
                iconTrailingConstraints.active = false
            } else {
                chatCountLabel.alpha = 0
                labelTrailingConstraints.active = false
                iconTrailingConstraints.active = true
            }
        } else {
            alpha = 0
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
