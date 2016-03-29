//
//  DatabaseTests.swift
//  SwishTests
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import XCTest
import RealmSwift
import CoreLocation
@testable import Swish

class DatabaseTests: XCTestCase {
    
    var otherUserIndex = 0
    var photoIndex = 0
    var chatMessageIndex = 0
    
    override func setUp() {
        super.setUp()
        // 사용 할지도 모르는 코드라 남겨둠
//        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        SwishDatabase.deleteAll()
        otherUserIndex = 0
        photoIndex = 0
    }
    
    override func tearDown() {
        super.tearDown()
        SwishDatabase.deleteAll()
    }
    
    // MARK: - Creations
    
    func testCreateMe() {
        let me = createMe()
        SwishDatabase.saveMe(me)
        XCTAssert(me == SwishDatabase.me())
    }
    
    func testCreateOtherUser() {
        let user = createOtherUser()
        let userId = user.id
        SwishDatabase.saveOtherUser(user)
        XCTAssert(user == SwishDatabase.otherUser(userId)!)
    }
    
    func testCreateSentPhoto() {
        SwishDatabase.saveMe(createMe())
        
        let photoOne = createPhoto()
        let photoTwo = createPhoto()
        
        SwishDatabase.saveSentPhoto(photoOne, serverId: sendPhoto(photoOne))
        SwishDatabase.saveSentPhoto(photoTwo, serverId: sendPhoto(photoTwo))
        
        XCTAssert(photoOne == SwishDatabase.photoWithId(photoOne.id)!)
        XCTAssert(photoTwo == SwishDatabase.photoWithId(photoTwo.id)!)
    }
    
    func testCreateReceivedPhoto() {
        SwishDatabase.saveMe(createMe())
        
        let userOne = createOtherUser()
        let userTwo = createOtherUser()
        SwishDatabase.saveOtherUser(userOne)
        SwishDatabase.saveOtherUser(userTwo)
        
        let photoOne = createReceivedPhoto()
        let photoTwo = createReceivedPhoto()
        SwishDatabase.saveReceivedPhoto(userOne, photo: photoOne)
        SwishDatabase.saveReceivedPhoto(userOne, photo: photoTwo)
        
        let photoThree = createReceivedPhoto()
        SwishDatabase.saveReceivedPhoto(userTwo, photo: photoThree)
        
        XCTAssert(photoOne == SwishDatabase.photoWithId(photoOne.id)!)
        XCTAssert(photoTwo == SwishDatabase.photoWithId(photoTwo.id)!)
    }
    
    func testCreateSentPhotoChatMessages() {
        SwishDatabase.saveMe(createMe())
        
        let photo = createPhoto()
        SwishDatabase.saveSentPhoto(photo, serverId: sendPhoto(photo))
        
        chatMessageIndex = 0
        var originalMessages = Array<ChatMessage>()
        for _ in 0...19 {
            let msg = createChatMessage(SwishDatabase.me().id)
            originalMessages.insert(msg, atIndex: 0)
            SwishDatabase.saveChatMessage(photo, chatMessage: msg)
        }
        
        let loadedMessages = SwishDatabase.loadChatMessages(photo.id, startIndex: 0, amount: 20)
        XCTAssertEqual(originalMessages, loadedMessages)
    }
    
    func testCreateReceivedPhotoChatMessages() {
        SwishDatabase.saveMe(createMe())
        
        let user = createOtherUser()
        SwishDatabase.saveOtherUser(user)
        
        let photo = createReceivedPhoto()
        SwishDatabase.saveReceivedPhoto(user, photo: photo)
        
        chatMessageIndex = 0
        var originalMessages = Array<ChatMessage>()
        for _ in 0...19 {
            let msg = createChatMessage(user.id)
            originalMessages.insert(msg, atIndex: 0)
            SwishDatabase.saveChatMessage(photo, chatMessage: msg)
        }
        
        let loadedMessages = SwishDatabase.loadChatMessages(photo.id, startIndex: 0, amount: 20)
        XCTAssertEqual(originalMessages, loadedMessages)
    }
    
    // MARK: - Deletions
    
    func testDeleteChatMessage() {
        SwishDatabase.saveMe(createMe())
        
        let user = createOtherUser()
        SwishDatabase.saveOtherUser(user)
        
        let photo = createReceivedPhoto()
        SwishDatabase.saveReceivedPhoto(user, photo: photo)
        
        let msg = createChatMessage(user.id)
        SwishDatabase.saveChatMessage(photo, chatMessage: msg)
        
        SwishDatabase.delete { (target: ChatMessage) -> Bool in
            return target == msg
        }
        XCTAssertEqual(SwishDatabase.loadChatMessages(photo.id, startIndex: 0, amount: 1).count, 0)
    }
    
    // MARK: - Updates
    
    func testUpdateOtherUser() {
        SwishDatabase.saveMe(createMe())
        
        let user = createOtherUser()
        SwishDatabase.saveOtherUser(user)
        
        let id = user.id
        
        let newUser = createOtherUser()
        newUser.id = id
        newUser.name = "new name!!"
        
        SwishDatabase.saveOtherUser(newUser)
        
        let users = SwishDatabase.objects(OtherUser)
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].id, id)
    }
    
    // MARK: - Performances
    
    func testQueryObjectPerformance() {
        SwishDatabase.saveMe(createMe())
        
        let photo = createPhoto()
        SwishDatabase.saveSentPhoto(photo, serverId: sendPhoto(photo))
        
        let count = 10000
        
        var msgs = Array<ChatMessage>()
        for _ in 0...count {
            msgs.append(self.createChatMessage(SwishDatabase.me().id))
        }
        SwishDatabase.saveChatMessages(photo, chatMessages: msgs)
        self.measureBlock {
            var cnt = 0
            let msg = SwishDatabase.loadChatMessages(photo.id, startIndex: count, amount: 1)[0]
            SwishDatabase.object({ (target: ChatMessage) -> Bool in
                cnt += 1
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
    
    func createOtherUser() -> OtherUser {
        otherUserIndex += 1
        let postfix = "\(otherUserIndex)"
        return OtherUser.create("opId\(postfix)") {
            $0.name = "opName\(postfix)"
            $0.about = "opAbout\(postfix)"
            $0.profileUrl = "opProfileUrl\(postfix)"
            $0.level = 1
            $0.recentlySentPhotoUrls = List<PhotoMetadata>(initialArray: [PhotoMetadata(url: "http://vignette4.wikia.nocookie.net/pokemon/images/6/64/004새박스아이콘.png/revision/latest?cb=20140106004106&path-prefix=ko")])
        }
    }
    
    func createReceivedPhoto() -> Photo {
        let photo = createPhoto()
        photo.id = createPhotoId()
        return photo
    }
    
    func createPhoto() -> Photo {
        let postfix = Int(arc4random_uniform(UInt32(100)))
        
        let postfixDouble = Double(postfix)
        let departLocation = CLLocation(latitude: 35.889972 + postfixDouble, longitude: 128.611332 + postfixDouble)
        let photo = Photo.create(Photo.ID(-1), message: "msg\(postfix)", departLocation: departLocation, departCountry: "Republic of Korea")
        photo.fileName = "fn\(postfix)"
        
        photo.unreadMessageCount = postfix
        photo.hasBlockedChat = postfix % 2 == 0
        photo.hasOpenedChatRoom = postfix % 2 == 0
        photo.arrivedLocation = CLLocation(latitude: 35.893105 + postfixDouble, longitude: 128.616192 + postfixDouble)
        
        return photo
    }
    
    func sendPhoto(photo: Photo) -> Photo.ID {
        return createPhotoId()
    }
    
    func createPhotoId() -> Photo.ID {
        photoIndex += 1
        return Photo.ID(photoIndex)
    }
    
    func createChatMessage(senderId: User.ID) -> ChatMessage {
        chatMessageIndex += 1
        return ChatMessage.create("Blahblah \(chatMessageIndex)", senderId: senderId) {
            (chatMessage: ChatMessage) -> () in
            chatMessage.state = ChatMessageSendState.Sending
        }
    }
}
