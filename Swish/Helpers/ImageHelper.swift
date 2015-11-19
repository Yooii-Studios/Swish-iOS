//
//  ImageHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

final class ImageHelper {
    
    enum Format {
        case PNG
    }
    
    final class func base64EncodedStringWith(image: UIImage) -> String! {
        return UIImagePNGRepresentation(image)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    final class func saveImage(image: UIImage, intoPath path: String, inFormat format: Format = .PNG) {
        switch format {
        case .PNG:
            UIImagePNGRepresentation(image)!.writeToFile(path, atomically: true)
        }
    }
    
    final class func convertToUpwardedImage(image: UIImage) -> UIImage {
        printImageOrientationDebug(image)
        guard image.imageOrientation != .Up else {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let upwardedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        printImageOrientationDebug(upwardedImage)
        
        return upwardedImage
    }
    
    // !!!: 디버그용 함수. 릴리즈시 비활성화 시킬것
    private class func printImageOrientationDebug(image: UIImage) {
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
}
