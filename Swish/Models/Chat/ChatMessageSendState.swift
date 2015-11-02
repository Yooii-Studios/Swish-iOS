//
//  ChatMessageState.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 3..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation

enum ChatMessageSendState: String {
    
    case None = "None"
    case Sending = "Sending"
    case Success = "Success"
    case Fail = "Fail"
}
