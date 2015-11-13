//
//  DeviceHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 29..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class DeviceHelper {
    
    static let isSimulator = TARGET_OS_SIMULATOR == 1
    static let isDevice = !isSimulator
    
    // Device Size
    static var deviceWidth: CGFloat {
        return mainScreenSize.width
    }
    static var deviceHeight: CGFloat {
        return mainScreenSize.height
    }
    private static var mainScreenSize: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
}
