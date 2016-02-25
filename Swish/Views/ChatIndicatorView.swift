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
        static let PriorityHigh: UILayoutPriority = 999
        static let PriorityLow: UILayoutPriority = 249
    }
    
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    @IBOutlet var iconTrailingConstraints: NSLayoutConstraint!
    @IBOutlet var labelTrailingConstraints: NSLayoutConstraint!
    
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
        } else {
            alpha = 0
        }
    }
    
    func setUnreadChatCount(unreadMessageCount: Int) {
        if unreadMessageCount > 0 {
            unreadMessageCountLabel.alpha = 1
            unreadMessageCountLabel.text = String(unreadMessageCount)
            
            iconTrailingConstraints.active = false
            iconTrailingConstraints.priority = Metric.PriorityLow
            labelTrailingConstraints.active = true
            labelTrailingConstraints.priority = Metric.PriorityHigh
        } else {
            unreadMessageCountLabel.alpha = 0
            
            labelTrailingConstraints.active = false
            labelTrailingConstraints.priority = Metric.PriorityLow
            iconTrailingConstraints.active = true
            iconTrailingConstraints.priority = Metric.PriorityHigh
        }
        layoutIfNeeded()
    }
}
