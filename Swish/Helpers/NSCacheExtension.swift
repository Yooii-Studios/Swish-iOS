//
//  PhotoImageCache.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 20..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

extension NSCache {
    class func create() -> NSCache {
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
