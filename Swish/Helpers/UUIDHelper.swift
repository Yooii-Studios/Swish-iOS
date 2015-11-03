//
//  UUIDHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 12..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import Foundation

final class UUIDHelper {
    
    final class func uuid() -> String {
        let wrapper = KeychainItemWrapper(identifier: "UUID", accessGroup: nil)
        var uuid = wrapper[kSecAttrAccount as String] as! String?
        
        if uuid == nil || uuid!.isEmpty {
            uuid = NSUUID().UUIDString
            wrapper[kSecAttrAccount as String] = uuid
        }
        return uuid!
    }
}
