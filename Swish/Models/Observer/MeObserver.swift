//
//  MeObserver.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 1. 12..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftTask

struct MeObserver: RealmObjectObservable {
    
    static func observeProfileUrl(owner: NSObject, handler: String -> Void) -> Canceller? {
            return startingStream(MeManager.me(), property: "profileUrl", owner: owner) {
                handler($0 as! String)
            }
    }
    
    static func observeName(owner: NSObject, handler: String -> Void) -> Canceller? {
        return startingStream(MeManager.me(), property: "name", owner: owner) {
            handler($0 as! String)
        }
    }
    
    static func observeAbout(owner: NSObject, handler: String -> Void) -> Canceller? {
        return startingStream(MeManager.me(), property: "about", owner: owner) {
            handler($0 as! String)
        }
    }
}
