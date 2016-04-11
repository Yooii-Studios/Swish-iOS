//
//  CountryInfo.swift
//  Swish
//
//  Created by YunSeungyong on 2016. 2. 27..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class CountryInfo {

    var name: String?
    var code: String?
    
    // MARK: - Singleton
    
    private struct Instance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: CountryInfo?
    }
    
    static var instance: CountryInfo {
        get {
            dispatch_once(&Instance.dispatchToken) {
                Instance.instance = CountryInfo()
            }
            return Instance.instance!
        }
    }
    
    // MARK: - Initializers
    
    private init() { }
    
}
