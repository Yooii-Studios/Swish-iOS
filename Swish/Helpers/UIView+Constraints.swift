//
//  UIView+Constraints.swift
//   특정 UIView의 관련 constraints를 모두 삭제하는 기능을 제공하는 extension
//  Swish
//
//  Created by Wooseong Kim on 2015. 10. 29..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /**
     Removes all related constrains for this view (including ones from super view)
     */
    func removeAllConstraints() {
        var targetConstraints = [NSLayoutConstraint]()
        
        for constraint in self.superview!.constraints {
            if constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self {
                targetConstraints.append(constraint)
            }
        }
        self.superview!.removeConstraints(targetConstraints)
        self.removeConstraints(self.constraints)
    }
}
