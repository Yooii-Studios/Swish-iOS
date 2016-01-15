//
//  UIView+ViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 1. 14..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
