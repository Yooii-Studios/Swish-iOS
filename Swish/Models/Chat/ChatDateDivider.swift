//
//  ChatDateDivider.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 3. 1..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import DateTools

class ChatDateDivider: NSObject, ChatItem {
    final let dateInfo: String
    
    init(eventTime: NSDate) {
        dateInfo = eventTime.formattedDateWithFormat("yyyy.MM.dd EEE")
        super.init()
    }
}
