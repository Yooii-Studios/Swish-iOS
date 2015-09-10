//
//  SwishTests.swift
//  SwishTests
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import XCTest
@testable import Swish
import RealmSwift
import CoreLocation

class SwishTests: XCTestCase {
    var opponentUserIndex = 0
    var photoIndex = 0
    var chatMessageIndex = 0
    
    override func setUp() {
        super.setUp()
//        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        SwishDatabase.deleteAll()
        opponentUserIndex = 0
        photoIndex = 0
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
    
    // MARK: - Creations
    func testCreateMe() {
        // Setup Me
        let me = createMe()
        SwishDatabase.saveMe(me)
        XCTAssert(me == SwishDatabase.me())
    }
    
    func testCreateOpponentUser() {
        // Setup Me
        let user = createOpponentUser()
        let userId = user.id
        SwishDatabase.saveOpponentUser(user)
        XCTAssert(user == SwishDatabase.opponentUser(userId)!)
    }
    
    func testCreateSentPhoto() {
        SwishDatabase.saveMe(createMe())
        
        let photoOne = createPhoto()
        let photoTwo = createPhoto()
        SwishDatabase.saveSentPhoto(photoOne)
        SwishDatabase.saveSentPhoto(photoTwo)
        
        XCTAssert(photoOne == SwishDatabase.photoWithId(photoOne.id)!)
        XCTAssert(photoTwo == SwishDatabase.photoWithId(photoTwo.id)!)
    }
    
    func testCreateReceivedPhoto() {
        SwishDatabase.saveMe(createMe())
        
        let userOne = createOpponentUser()
        let userTwo = createOpponentUser()
        SwishDatabase.saveOpponentUser(userOne)
        SwishDatabase.saveOpponentUser(userTwo)
        
        let photoOne = createPhoto()
        let photoTwo = createPhoto()
        SwishDatabase.saveReceivedPhoto(userOne.id, photo: photoOne)
        SwishDatabase.saveReceivedPhoto(userOne.id, photo: photoTwo)
        
        let photoThree = createPhoto()
        SwishDatabase.saveReceivedPhoto(userTwo.id, photo: photoThree)
        
        XCTAssert(photoOne == SwishDatabase.photoWithId(photoOne.id)!)
        XCTAssert(photoTwo == SwishDatabase.photoWithId(photoTwo.id)!)
    }
    
    func testCreateSentPhotoChatMessages() {
        SwishDatabase.saveMe(createMe())
        
        let photo = createPhoto()
        SwishDatabase.saveSentPhoto(photo)
        
        chatMessageIndex = 0
        var originalMessages = Array<ChatMessage>()
        for _ in 0...19 {
            let msg = createChatMessage()
            originalMessages.append(msg)
            SwishDatabase.saveChatMessage(photo, chatMessage: msg)
        }
        
        let loadedMessages = SwishDatabase.loadChatMessages(photo.id, startIndex: 0, amount: 20)
        XCTAssertEqual(originalMessages, loadedMessages)
    }
    
    func testCreateReceivedPhotoChatMessages() {
        SwishDatabase.saveMe(createMe())
        
        let user = createOpponentUser()
        SwishDatabase.saveOpponentUser(user)
        
        let photo = createPhoto()
        SwishDatabase.saveReceivedPhoto(user.id, photo: photo)
        
        chatMessageIndex = 0
        var originalMessages = Array<ChatMessage>()
        for _ in 0...19 {
            let msg = createChatMessage()
            originalMessages.append(msg)
            SwishDatabase.saveChatMessage(photo, chatMessage: msg)
        }
        
        let loadedMessages = SwishDatabase.loadChatMessages(photo.id, startIndex: 0, amount: 20)
        XCTAssertEqual(originalMessages, loadedMessages)
    }
    
    // MARK: - Deletions
    func testDeleteChatMessage() {
        SwishDatabase.saveMe(createMe())
        
        let user = createOpponentUser()
        SwishDatabase.saveOpponentUser(user)
        
        let photo = createPhoto()
        SwishDatabase.saveReceivedPhoto(user.id, photo: photo)
        
        let msg = createChatMessage()
        SwishDatabase.saveChatMessage(photo, chatMessage: msg)
        
//        let id = photo.id
//        
//        SwishDatabase.delete { (target: Photo) -> Bool in
//            return target.id == photo.id
//        }
        
        SwishDatabase.delete { (target: ChatMessage) -> Bool in
            return target == msg
        }
        XCTAssertEqual(SwishDatabase.loadChatMessages(photo.id, startIndex: 0, amount: 1).count, 0)
    }
    
    // MARK: - Updates
    func testUpdateOpponentUser() {
        SwishDatabase.saveMe(createMe())
        
        let user = createOpponentUser()
        SwishDatabase.saveOpponentUser(user)
        
        let id = user.id
        
        let newUser = createOpponentUser()
        newUser.id = id
        newUser.name = "new name!!"
        
        SwishDatabase.saveOpponentUser(newUser)
        
        let users = SwishDatabase.objects(OpponentUser)
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].id, id)
    }
    
    // MARK: - Performances
    func testQueryObjectPerformance() {
        SwishDatabase.saveMe(createMe())
        
        let photo = createPhoto()
        SwishDatabase.saveSentPhoto(photo)
        
        let count = 10000
        
//        self.measureBlock {
            var msgs = Array<ChatMessage>()
            for _ in 0...count {
                msgs.append(self.createChatMessage())
            }
            SwishDatabase.saveChatMessages(photo, chatMessages: msgs)
//        }
        self.measureBlock {
            var cnt = 0
            let msg = SwishDatabase.loadChatMessages(photo.id, startIndex: count, amount: 1)[0]
            SwishDatabase.object({ (target: ChatMessage) -> Bool in
                cnt++
                return target == msg
            })
            print("qwerasdf CNT: \(cnt)")
        }
    }
    
    // MARK: - Object creation methods
    func createMe() -> Me {
        return Me.create("myId", token: "token", builder: {(me: Me) -> () in
            me.name = "myName"
            me.about = "myAbout"
            me.profileUrl = "http://pds5.egloos.com/logo/200702/06/28/e0005928.jpg"
            me.level = 1
            me.totalExpForNextLevel = 10
            me.currentExp = 0
        })
    }
    
    func createOpponentUser() -> OpponentUser {
        let postfix = "\(opponentUserIndex++)"
        return OpponentUser.create("opId\(postfix)", builder: { (user: OpponentUser) -> () in
            user.name = "opName\(postfix)"
            user.about = "opAbout\(postfix)"
            user.profileUrl = "opProfileUrl\(postfix)"
            user.level = 1
            user.recentlySentPhotoUrls.append(PhotoMetadata(url: "http://vignette4.wikia.nocookie.net/pokemon/images/6/64/004새박스아이콘.png/revision/latest?cb=20140106004106&path-prefix=ko"))
        })
    }
    
    func createPhoto() -> Photo {
        let postfixInt = photoIndex++
        let postfix = "\(postfixInt)"
        return Photo.create(Photo.ID(postfix)!, builder: { (photo: Photo) -> () in
            photo.fileName = "fn\(postfix)"
            photo.message = "msg\(postfix)"
            
            photo.unreadMessageCount = postfixInt
            photo.hasBlockedChat = postfixInt % 2 == 0
            photo.hasOpenedChatRoom = postfixInt % 2 == 0
            let postfixDouble = Double(postfixInt)
            photo.departLocation = CLLocation(latitude: 35.889972 + postfixDouble, longitude: 128.611332 + postfixDouble)
            photo.arrivedLocation = CLLocation(latitude: 35.893105 + postfixDouble, longitude: 128.616192 + postfixDouble)
        })
    }
    
    func createChatMessage() -> ChatMessage {
        let index = chatMessageIndex++
        return ChatMessage.create("Blahblah \(index)") {
            (chatMessage: ChatMessage) -> () in
            chatMessage.state = ChatMessageSendState.Sending
        }
    }
}
