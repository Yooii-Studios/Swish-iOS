//
//  SystemSettingsHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 24..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class SystemSettingsHelper {
    
    final class func openSwishSystemSettings() {
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
