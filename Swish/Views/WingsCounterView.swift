//
//  WingsCounterView.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 3. 3..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable
import SwiftyColor

@IBDesignable
class WingsCounterView: NibDesignable {
    
    @IBOutlet weak var leftWingsLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var leftTimeSapceView: UIView! // 간격을 메꾸기 위해 추가한 뷰
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = 0x000000 ~ 0%
//        leftTimeLabel.layer.cornerRadius = leftTimeLabel.frame.height / 2
//        leftTimeLabel.layer.cornerRadius = Metric.CornerRadius
//        leftTimeLabel.layer.masksToBounds = true
//        layer.cornerRadius = Metric.CornerRadius
//        layer.masksToBounds = true
        
        let radius = leftTimeLabel.frame.height / 2
        let maskPath = UIBezierPath(roundedRect: leftTimeLabel.bounds,
            byRoundingCorners: [.BottomRight, .TopRight],
            cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.CGPath
        leftTimeLabel.layer.mask = shape
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
