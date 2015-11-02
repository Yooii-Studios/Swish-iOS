//
//  ChatMessage.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 3..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation
import RealmSwift

final class ChatMessage: Object {
    
    private static let defaultState = ChatMessageSendState.None
    private static let invalidReceivedTime = NSTimeInterval.NaN
    
    // MARK: - Attributes
    
    dynamic var message = ""
    dynamic var receivedTimeIntervalSince1970 = invalidReceivedTime
    var receivedDate:NSDate { return _receivedDate }
    var state: ChatMessageSendState {
        get {
            return ChatMessageSendState(rawValue: stateRaw) ?? ChatMessage.defaultState
        }
        set (newState) {
            stateRaw = newState.rawValue
        }
    }
    var sender: User {
        let me = SwishDatabase.me()
        return senderId == me.id ? me : SwishDatabase.otherUser(senderId)!
    }
    var receiver: User {
        let me = SwishDatabase.me()
        return sender == me ? SwishDatabase.otherUser(senderId)! : me
    }
    
    // MARK: - Realm backlink
    
    var photo: Photo {
        return linkingObjects(Photo.self, forProperty: "chatMessages")[0]
    }
    
    // MARK: - Init
    
    private convenience init(message: String, senderId: User.ID, eventTime: NSDate = NSDate()) {
        self.init()
        self.message = message
        self.senderId = senderId
        self._receivedDate = eventTime
    }
    
    // MARK: - Realm support
    
    private var _receivedDate: NSDate {
        get {
            // FIXME: Creates an instance everytime when receivedDate is retrieved.
            // May cause performance issue(memory/speed-wise).
            return NSDate(timeIntervalSince1970: receivedTimeIntervalSince1970)
        }
        set (newReceivedDate) {
            receivedTimeIntervalSince1970 = newReceivedDate.timeIntervalSince1970
        }
    }
    
    private dynamic var stateRaw = defaultState.rawValue
    private dynamic var senderId = User.invalidId
    
    override static func ignoredProperties() -> [String] {
        return ["state", "sender", "receiver", "sender", "receiver"]
    }
    
    final class func create(message: String, senderId: User.ID,
        builder: (ChatMessage) -> () = RealmObjectBuilder.builder) -> ChatMessage {
        let chatMessage = ChatMessage(message: message, senderId: senderId)
        builder(chatMessage)
        return chatMessage
    }
}

func == (left: ChatMessage, right: ChatMessage) -> Bool {
    return left.photo == right.photo && left.message == right.message
        && left.receivedDate.compare(right.receivedDate) == NSComparisonResult.OrderedSame
}
