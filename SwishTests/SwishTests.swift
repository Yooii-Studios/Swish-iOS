//
//  SwishTests.swift
//  SwishTests
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import XCTest
@testable import Swish

class SwishTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        SwishDatabase.deleteAll()
        
        // Save Me
        SwishDatabase.saveMe(MeBuilder.create("myId", token: "token", builder: {(me: Me) -> () in}))
    }
    
    override func tearDown() {
        // Put teardown code here.
        super.tearDown()
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func testMe() {
        // Save Photo
        let photoOne = PhotoBuilder.create(1, builder: { $0.message = ""; $0.message = "" })
        let photoTwo = PhotoBuilder.create(2, builder: { (Photo) -> () in })
        SwishDatabase.saveSentPhoto(photoOne)
        SwishDatabase.saveSentPhoto(photoTwo)
        
        // Save ChatMessage
        let chatMessageOne = ChatMessageBuilder.create("first") { (ChatMessage) -> () in }
        let chatMessageTwo = ChatMessageBuilder.create("second") { (ChatMessage) -> () in }
        let chatMessageThree = ChatMessageBuilder.create("third") { (ChatMessage) -> () in }
        let chatMessageFour = ChatMessageBuilder.create("fourth") { (ChatMessage) -> () in }
        SwishDatabase.saveChatMessages(photoOne, chatMessage: chatMessageOne)
        SwishDatabase.saveChatMessages(photoOne, chatMessage: chatMessageTwo)
        SwishDatabase.saveChatMessages(photoOne, chatMessage: chatMessageThree)
        SwishDatabase.saveChatMessages(photoTwo, chatMessage: chatMessageFour)
        
        let sendPhotoCount = SwishDatabase.sentPhotos().count
        let messageInPhotoCount = SwishDatabase.loadChatMessages(1, startIndex: 0, amount: 100).count
        
        XCTAssertEqual(sendPhotoCount, 2)
        XCTAssertEqual(messageInPhotoCount, 3)
    }
    
    func testOpponentUser() {
        // Save User
        SwishDatabase.saveOpponentUser(OpponentUserBuilder.create("opId1", builder: { (OpponentUser) -> () in
            
        }))
        SwishDatabase.saveOpponentUser(OpponentUserBuilder.create("opId2", builder: { (OpponentUser) -> () in
            
        }))
        
        // Save Photo
        let photoOne = PhotoBuilder.create(3, builder: { $0.message = ""; $0.message = "" })
        let photoTwo = PhotoBuilder.create(6, builder: { (Photo) -> () in })
        SwishDatabase.saveReceivedPhoto("opId1", photo: photoOne)
        SwishDatabase.saveReceivedPhoto("opId2", photo: photoTwo)
        
        // Save ChatMessage
        let chatMessageOne = ChatMessageBuilder.create("first") { (ChatMessage) -> () in }
        let chatMessageTwo = ChatMessageBuilder.create("second") { (ChatMessage) -> () in }
        let chatMessageThree = ChatMessageBuilder.create("third") { (ChatMessage) -> () in }
        let chatMessageFour = ChatMessageBuilder.create("fourth") { (ChatMessage) -> () in }
        SwishDatabase.saveChatMessages(photoOne, chatMessage: chatMessageOne)
        SwishDatabase.saveChatMessages(photoOne, chatMessage: chatMessageTwo)
        SwishDatabase.saveChatMessages(photoOne, chatMessage: chatMessageThree)
        SwishDatabase.saveChatMessages(photoTwo, chatMessage: chatMessageFour)
        
        let receivedPhotoCount = SwishDatabase.receivedPhotos().count
        let messageInPhotoCount = SwishDatabase.loadChatMessages(6, startIndex: 0, amount: 100).count
        
        XCTAssertEqual(receivedPhotoCount, 2)
        XCTAssertEqual(messageInPhotoCount, 1)
    }
}
