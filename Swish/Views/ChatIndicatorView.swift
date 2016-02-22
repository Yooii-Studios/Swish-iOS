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
        static let CornerRadius: CGFloat = 12
    }
    
    @IBOutlet weak var chatCountLabel: UILabel!
    @IBOutlet weak var iconTrailingConstraints: NSLayoutConstraint!
    @IBOutlet weak var labelTrailingConstraints: NSLayoutConstraint!
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = 0x000000 ~ 29% // 4C
        layer.cornerRadius = Metric.CornerRadius
        layer.masksToBounds = true
    }
    
    func setUpWithPhoto(photo: Photo) {
        if photo.hasOpenedChatRoom {
            alpha = 1
            
            if photo.unreadMessageCount > 0 {
                chatCountLabel.alpha = 1
                chatCountLabel.text = String(photo.unreadMessageCount)
                
                labelTrailingConstraints.active = true
                labelTrailingConstraints.priority = UILayoutPriorityRequired
                iconTrailingConstraints.active = false
            } else {
                chatCountLabel.alpha = 0
                
                labelTrailingConstraints.active = false
                iconTrailingConstraints.active = true
                iconTrailingConstraints.priority = UILayoutPriorityRequired
            }
            layoutIfNeeded()
        } else {
            alpha = 0
        }
    }
}
