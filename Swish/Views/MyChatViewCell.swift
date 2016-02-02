//
//  MyChatViewCell.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 2..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class MyChatViewCell: UITableViewCell {

    // TODO: 하나씩 구현해줄 것
    @IBOutlet weak var messageLabel: UILabel!
    
    final func initWithChatMessage(chatMessage: ChatMessage) {
        messageLabel.text = chatMessage.message
    }
}
