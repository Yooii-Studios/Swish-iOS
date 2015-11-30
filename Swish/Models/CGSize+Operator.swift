//
//  CGSize+Operator.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 19..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

extension CGSize {}

func /(size: CGSize, denominator: CGFloat) -> CGSize {
    return CGSizeMake(size.width / denominator, size.height / denominator)
}

func /(size: CGSize, denominator: Int) -> CGSize {
    return size / CGFloat(denominator)
}
