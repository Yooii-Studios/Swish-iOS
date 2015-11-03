//
//  NSCache+LowMemory.swift
//   시스템에서 low memory 경고를 받은 경우 캐시를 비워주는 기능 추가
//
//  Swish
//
//  Created by 정동현 on 2015. 10. 20..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

extension NSCache {
    
    class func createWithMemoryWarningObserver() -> NSCache {
        let cache = NSCache()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserverForName(UIApplicationDidReceiveMemoryWarningNotification,
            object: nil, queue: NSOperationQueue.mainQueue(),
            usingBlock: { (notification : NSNotification!) -> Void in
                cache.removeAllObjects()
            }
        )
        return cache
    }
}
