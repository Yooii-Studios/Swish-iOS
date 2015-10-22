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
    enum Format { case PNG }
    
    final class func base64EncodedStringWith(image: UIImage) -> String! {
        return UIImagePNGRepresentation(image)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    final class func saveImage(image: UIImage, intoPath path: String, inFormat format: Format = .PNG) {
        switch format {
        case .PNG:
            UIImagePNGRepresentation(image)!.writeToFile(path, atomically: true)
        }
    }
}
