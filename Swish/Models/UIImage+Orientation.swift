//
//  UIImage+Orientation.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 19..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

// !!!: 디버그용 함수. 릴리즈시 비활성화 시킬것
private func printImageOrientationDebug(image: UIImage) {
    var message: String!
    switch image.imageOrientation {
    case .Up:
        message = "Up"
    case .Down:
        message = "Down"
    case .Left:
        message = "Left"
    case .Right:
        message = "Right"
    case .UpMirrored:
        message = "UpMirrored"
    case .DownMirrored:
        message = "DownMirrored"
    case .LeftMirrored:
        message = "LeftMirrored"
    case .RightMirrored:
        message = "RightMirrored"
    }
    print(message)
}

extension UIImage {
    
    final var upwardedImage: UIImage {
        printImageOrientationDebug(self)
        guard imageOrientation != .Up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        drawInRect(CGRectMake(0, 0, size.width, size.height))
        let upwardedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        printImageOrientationDebug(upwardedImage)
        
        return upwardedImage
    }
}
