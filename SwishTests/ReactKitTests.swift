//
//  ReactKitTests.swift
//   ReactKit의 사용법과 Realm을 사용한 KVO 패턴 동작 확인 및 사용법 기록을 위해 작성
//
//  Swish
//
//  Created by 정동현 on 2015. 11. 11..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import XCTest
import ReactKit
@testable import Swish

class ReactKitTests: XCTestCase {
    
    dynamic var message = ""

    override func setUp() {
        super.setUp()
        
        SwishDatabase.deleteAll()
        
        let me = Me.create("myId", token: "token", builder: {(me: Me) -> () in
            me.name = "myName"
            me.about = "myAbout"
            me.profileUrl = "http://pds5.egloos.com/logo/200702/06/28/e0005928.jpg"
            me.level = 1
            me.totalExpForNextLevel = 10
            me.currentExp = 0
        })
        SwishDatabase.saveMe(me)
        
        message = "First"
    }
    
    override func tearDown() {
        SwishDatabase.deleteAll()
        super.tearDown()
    }
    
    func testRealmObjectUpdatePropagation() {
        let photo = Photo.create(message: "testMessage", departLocation: CLLocation(latitude: 127.01, longitude: 36.01))
        SwishDatabase.saveSentPhoto(photo, serverId: 0, newFileName: "qwerasdf")
        
        let photoMessageStream = KVO.stream(photo, "message").ownedBy(self)
        (self, "message") <~ photoMessageStream
        photoMessageStream ~> {
            print("photoMessageStream: \($0)")
        }
        
        try! SwishDatabase.realm.write {
            photo.message = "Second"
        }
        
        XCTAssertEqual(message, photo.message)
    }
}
