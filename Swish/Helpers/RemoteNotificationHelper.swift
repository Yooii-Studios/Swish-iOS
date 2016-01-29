//
//  RemoteNotificationHelper.swift
//  Swish
//
//  Created by YunSeungyong on 2016. 1. 29..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class RemoteNotificationHelper {
    
    final class func trimDeviceToken(deviceTokenData: NSData) -> String {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        let deviceTokenString: String = ( deviceTokenData.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        return deviceTokenString
    }
}
