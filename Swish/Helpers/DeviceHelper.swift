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
    static var IPhone6UIScreenPixelWidth: CGFloat = 750.0
    static var deviceWidth: CGFloat {
        return mainScreenSize.width
    }
    static var deviceHeight: CGFloat {
        return mainScreenSize.height
    }
    static var devicePixelWidth: CGFloat {
        return deviceWidth * mainScreenScale
    }
    static var devicePixelHeight: CGFloat {
        return deviceHeight * mainScreenScale
    }
    private static var mainScreenSize: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    private static var mainScreenScale: CGFloat {
        return UIScreen.mainScreen().scale
    }
}
