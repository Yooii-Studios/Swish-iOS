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
        initViews()
    }
    
    private func initViews() {
        backgroundColor = 0x000000 ~ 0%
        makeRightCornerRounded()
    }
    
    private func makeRightCornerRounded() {
        let radius = leftTimeLabel.frame.height / 2
        let maskPath = UIBezierPath(roundedRect: leftTimeLabel.bounds,
            byRoundingCorners: [.BottomRight, .TopRight],
            cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.CGPath
        leftTimeLabel.layer.mask = shape
    }

    final func refreshWingsCount(wingsCount: Int) {
        leftWingsLabel.text = String(wingsCount)
    }
    
    final func refreshLeftTime(timeLeftInSec: Int?) {
        if let time = timeLeftInSec {
            let minutesString = String(format:("%02d"), time / 60)
            let secondsString = String(format:("%02d"), time % 60)
            leftTimeLabel.text = "\(minutesString):\(secondsString)"
        } else {
            leftTimeLabel.text = "30:00"
        }
    }
    
    override func prepareForInterfaceBuilder() {
        initViews()
    }
}
