//
//  CircleButton.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 2..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import SwiftyColor
import NibDesignable

// TODO: 추후 원형 버튼으로 만든 후 전체적인 색, 그림자 관련 로직 수정해줄 것
@IBDesignable
class CircleButton: NibDesignable {

    struct Color {
        static let unselectedBackground = 0xe1e1e1~
        static let disabled = 0xebebeb~
    }
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var foregroundView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    @IBInspectable var backgroundCircleColor: UIColor! {
        didSet {
            backgroundView.backgroundColor = backgroundCircleColor
        }
    }
    @IBInspectable var foregroundCircleColor: UIColor! {
        didSet {
            foregroundView.backgroundColor = foregroundCircleColor
        }
    }
    @IBInspectable var strokeWidth: CGFloat = 8.0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    @IBInspectable var image: UIImage = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    @IBInspectable var imageSize: CGFloat = 40 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    /*
    @IBInspectable var enableShadow: Bool = false {
        didSet {
            // TODO: 그림자 추후 구현 예정
        }
    }
    */
    
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
    // TODO: 그림자 관련 작업 시 필요해질 것 같아서 남김
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func updateConstraints() {
        foregroundView.snp_updateConstraints { make in
            make.left.equalTo(backgroundView!.snp_left).offset(strokeWidth)
            make.top.equalTo(backgroundView!.snp_top).offset(strokeWidth)
            make.right.equalTo(backgroundView!.snp_right).offset(strokeWidth)
            make.bottom.equalTo(backgroundView!.snp_bottom).offset(strokeWidth)
//            let edgeInsets = UIEdgeInsetsMake(strokeWidth, strokeWidth, strokeWidth, strokeWidth)
//            make.edges.equalTo(backgroundView!).inset(edgeInsets)
        }
        
        imageView.snp_updateConstraints { make in
            make.size.equalTo(imageSize)
        }
        
        super.updateConstraints()
    }
    override func prepareForInterfaceBuilder() {
        if image.size == CGSizeZero {
            let bundle = NSBundle(forClass: self.dynamicType)
            image = UIImage(named: "ic_photo_like_inactive", inBundle: bundle, compatibleWithTraitCollection: nil)!
        }
    }
}
