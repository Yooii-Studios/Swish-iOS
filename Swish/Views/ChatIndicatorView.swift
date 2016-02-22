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

    struct Metric {
        static let InnerMargin: CGFloat = 6
        static let OuterMargin: CGFloat = 8
    }
    
    @IBOutlet var chatCountLabel: UILabel!
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
//                iconTrailingConstraints.priority = 249
//                iconTrailingConstraints.active = false
//                labelTrailingConstraints.priority = 1000
            } else {
                chatCountLabel.alpha = 0
//                iconTrailingConstraints.active = true
//                iconTrailingConstraints.priority = 1000
//                iconTrailingConstraints.constant = Metric.OuterMargin
//                labelTrailingConstraints.priority = 249
//                chatCountLabel.removeAllConstraints()
            }
//            layoutIfNeeded()
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
