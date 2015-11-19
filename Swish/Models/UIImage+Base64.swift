//
//  UIImage+Base64.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 19..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

extension UIImage {
    
    final var base64EncodedString: String! {
        return UIImagePNGRepresentation(self)?.base64EncodedStringWithOptions(
            NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
}
