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
    final class func base64EncodedStringWith(image: UIImage) -> String? {
        return UIImagePNGRepresentation(image)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
}
