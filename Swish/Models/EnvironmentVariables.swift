//
//  EnvironmentVariables.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 10..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class EnvironmentVariables {
    static let IsTesting = NSProcessInfo.processInfo().environment["Testing"]?.compare("true") == .OrderedSame
}
