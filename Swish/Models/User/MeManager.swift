//
//  MeUtils.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 12..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

final class MeManager {
    
    typealias DefaultCallback = () -> ()
    
    class func me() -> Me {
        return SwishDatabase.me()
    }
    
    class func registerMe(name: String? = nil, about: String? = nil, image: UIImage? = nil,
        onSuccess: ((me: Me) -> ())? = nil, onFail: DefaultCallback? = nil) {
            UserServer.registerMe(name, about: about, image: image,
                onSuccess: { (me) -> () in
                    SwishDatabase.saveMe(me)
                    onSuccess?(me: me)
                }, onFail: { (error) -> () in
                    onFail?()
            })
    }
    
    class func updateMe(name: String? = nil, about: String? = nil,
        onSuccess: DefaultCallback? = nil, onFail: DefaultCallback? = nil) {
            let userId = SwishDatabase.me().id
            UserServer.updateMe(userId, name: name, about: about,
                onSuccess: { (result) -> () in
                    SwishDatabase.updateMe(name, about: about)
                    onSuccess?()
                }, onFail: { (error) -> () in
                    onFail?()
            })
    }
    
    class func updateMyProfileImage(image: UIImage,
        onSuccess: ((String) -> ())? = nil, onFail: DefaultCallback? = nil) {
            let userId = SwishDatabase.me().id
            UserServer.updateMyProfileImage(userId, image: image,
                onSuccess: { (profileImageUrl) -> () in
                    SwishDatabase.updateMyProfileImage(profileImageUrl)
                    onSuccess?(profileImageUrl)
                }, onFail: { (error) -> () in
                    onFail?()
            })
    }
    
    class func updateMyActivityStatus(onSuccess: ((record: UserActivityRecord) -> ())? = nil,
        onFail: DefaultCallback? = nil) {
            let userId = SwishDatabase.me().id
            UserServer.activityRecordWith(userId,
                onSuccess: { (record) -> () in
                    SwishDatabase.updateMyActivityRecord(record)
                    onSuccess?(record: record)
                }, onFail: { (error) -> () in
                    onFail?()
            })
    }
    
    class func saveMyLevelInfo(userLevelInfo: UserLevelInfo) {
        SwishDatabase.updateMyLevelInfo(userLevelInfo)
    }
}
