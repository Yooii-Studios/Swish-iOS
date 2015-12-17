//
//  CircleButton.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 2..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import SwiftyColor

// TODO: 추후 원형 버튼으로 만든 후 전체적인 색 관련 로직 수정해줄 것
@IBDesignable
class CircleButton: UIView {

    struct Color {
        static let unselectedBackground = 0xe1e1e1~
        static let disabled = 0xebebeb~
    }
    
    // TODO: 추후 더 제대로 된 색 구현 필요
    @IBInspectable var foregroundCircleColor: UIColor! {
        didSet {
            backgroundColor = foregroundCircleColor
        }
    }
    @IBInspectable var backgroundCircleColor: UIColor! {
        didSet {
            backgroundColor = backgroundCircleColor
        }
    }
    var imageView: UIImageView!
    
    final func setSelected(isSelected: Bool) {
        if isSelected {
            backgroundColor = backgroundCircleColor
        } else {
            backgroundColor = Color.unselectedBackground
        }
    }
    
    final func setDisabled() {
        userInteractionEnabled = false
        foregroundCircleColor = Color.disabled
        backgroundCircleColor = Color.disabled
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
