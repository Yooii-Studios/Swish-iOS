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
import UIColor_Hex_Swift

// TODO: 추후 원형 버튼으로 만든 후 전체적인 색, 그림자 관련 로직 수정해줄 것
@IBDesignable
class CircleButton: NibDesignable {

    struct Color {
        static let unselectedBackground = 0xe1e1e1~
        static let disabled = 0xebebeb~
        static let shadow = UIColor(rgba: "#00000028")
    }
    
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var circleBackgroundColor: UIColor! = UIColor.clearColor()
    @IBInspectable var circleForegroundColor: UIColor! = UIColor.clearColor()
    @IBInspectable var dropShadowEnabled: Bool = false {
        didSet {
            if dropShadowEnabled {
                layer.masksToBounds = false
                layer.shadowColor = Color.shadow.CGColor
                layer.shadowOffset = CGSizeMake(1, 1);
                layer.shadowOpacity = 1;
                layer.shadowRadius = 1.0
            }
        }
    }
    @IBInspectable var innerShadowEnabled: Bool = false
    @IBInspectable var imageSize: CGFloat = 0 {
        didSet {
            let x = self.frame.width / 2 - imageSize / 2
            let y = self.frame.height / 2 - imageSize / 2
            let frame = CGRect.init(x: x, y: y, width: imageSize, height: imageSize)
            imageView.frame = frame
        }
    }
    @IBInspectable var image: UIImage! = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    private var imageView: UIImageView!
    @IBInspectable var touchEffectEnabled: Bool = false
    private var isTouchesBegan = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private func _init() {
        backgroundColor = UIColor.clearColor()
        initImageView()
    }
    
    private func initImageView() {
        imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        addSubview(imageView)
    }

    
    final func setSelected(isSelected: Bool) {
//        if isSelected {
//            backgroundView.backgroundColor = backgroundCircleColor
//        } else {
//            backgroundView.backgroundColor = Color.unselectedBackground
//        }
    }
    
    final func setDisabled() {
//        userInteractionEnabled = false
//        foregroundCircleColor = Color.disabled
//        backgroundCircleColor = Color.disabled
    }
    
    override func drawRect(rect: CGRect) {
        drawCircle(rect, withColor: circleBackgroundColor)
        
        let insetRect = rect.insetBy(dx: borderWidth, dy: borderWidth)
        if !isTouchesBegan || !touchEffectEnabled {
            if innerShadowEnabled {
                let shadowRect = insetRect.offsetBy(dx: 1, dy: 1)
                drawCircle(shadowRect, withColor: Color.shadow)
            }
            drawCircle(insetRect, withColor: circleForegroundColor)
        }
    }
    
    private func drawCircle(rect: CGRect, withColor color: UIColor) {
        color.setFill()
        let circlePath = UIBezierPath(ovalInRect: rect)
        circlePath.fill()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first != nil {
            isTouchesBegan = true
            setNeedsDisplay()
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first != nil {
            isTouchesBegan = false
            setNeedsDisplay()
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func prepareForInterfaceBuilder() {
//        if image.size == CGSizeZero {
//            let bundle = NSBundle(forClass: self.dynamicType)
//            image = UIImage(named: "ic_photo_like_inactive", inBundle: bundle, compatibleWithTraitCollection: nil)
//        }
    }
}
