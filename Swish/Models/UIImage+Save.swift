//
//  UIImage+Save.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 19..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

extension UIImage {
    
    enum Format {
        case PNG
    }
    
    final func saveIntoPath(path: String, inFormat format: Format = .PNG) {
        switch format {
        case .PNG:
            UIImagePNGRepresentation(self)!.writeToFile(path, atomically: true)
        }
    }
}
