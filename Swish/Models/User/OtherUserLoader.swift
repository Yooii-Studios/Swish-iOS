//
//  OtherUserLoader.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 12..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import Alamofire

typealias LoadUserTag = String

final class OtherUserLoader {
    
    // MARK: - Singleton
    
    private struct Instance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: OtherUserLoader?
    }
    
    static var instance: OtherUserLoader {
        get {
            dispatch_once(&Instance.dispatchToken) {
                Instance.instance = OtherUserLoader()
            }
            return Instance.instance!
        }
    }
    
    // MARK: - Init
    
    private init() { }
    
    // MARK: - Constants
    
    private static let cacheInvalidateInterval: NSTimeInterval = 2 * 60 * 60 * 1000
    
    // MARK: - Attributes
    
    private let callbacks = Callbacks()
    
    final func loadOtherUserWithRequest(request: OtherUserFetchRequest) {
        if !notifyIfCacheSuitableToRequest(request) {
            print("OtherUser cache miss.")
            let isFetching = self.isFetching(request)
            addRequest(request)
            notifyPrepareWithRequest(request)
            if !isFetching {
                print("OtherUser not fetching. Request fetch.")
                fetchWithRequest(request)
            } else {
                print("OtherUser fetching. Registered callback.")
            }
        }
    }
    
    final func cancelWithTag(tag: LoadUserTag) {
        callbacks.cancelWithTag(tag)
    }
    
    // MARK: - Helper functions
    
    private final func notifyIfCacheSuitableToRequest(request: OtherUserFetchRequest) -> Bool {
        var notified = false
        if let user = OtherUserLoader.cachedOtherUserWithId(request.userId)
            where !OtherUserLoader.isUserExpired(user)
                && OtherUserLoader.isOtherUserSuitableForRequest(user, request: request) {
                    print("OtherUser cache hit!!")
                    request.callback.successCallback(otherUser: user)
                    notified = true
        }
        return notified
    }
    
    private final func isFetching(request: OtherUserFetchRequest) -> Bool {
        return callbacks.containsUserId(request.userId)
    }
    
    private final func addRequest(request: OtherUserFetchRequest) {
        callbacks.addWithRequest(request)
    }
    
    private final func notifyPrepareWithRequest(request: OtherUserFetchRequest) {
        if let cachedUser = SwishDatabase.otherUser(request.userId) {
            callbacks.notifyOnPrepareWithUserId(request.userId, user: cachedUser)
        }
    }
    
    private final func fetchWithRequest(request: OtherUserFetchRequest) {
        UserServer.otherUserWith(request.userId,
            onSuccess: { (otherUser) -> () in
                SwishDatabase.saveOtherUser(otherUser)
                self.notifySuccess(request.userId, user: otherUser)
            }, onFail: { (error: SwishError) -> () in
                self.notifyFailure(request.userId)
        })
    }
    
    private final func notifySuccess(userId: User.ID, user: OtherUser) {
        callbacks.notifyOnSuccessWithUserId(userId, user: user)
    }
    
    private final func notifyFailure(userId: User.ID) {
        callbacks.notifyOnFailureWithUserId(userId)
    }
    
    private final class func isOtherUserSuitableForRequest(user: OtherUser, request: OtherUserFetchRequest) -> Bool {
        var suitable = true
        let options = request.options
        if user.recentlySentPhotoUrls == nil && !options.ignoreRecentlySentPhotoMetadata {
            suitable = false
        }
        return suitable
    }
    
    private final class func cachedOtherUserWithId(userId: User.ID) -> OtherUser? {
        return SwishDatabase.otherUser(userId)
    }
    
    private final class func isUserExpired(user: OtherUser) -> Bool {
        return NSDate().timeIntervalSince1970 - user.fetchedTimeIntervalSince1970 > cacheInvalidateInterval
    }
}

struct OtherUserFetchRequest {
    
    typealias Builder = (request: OtherUserFetchRequest) -> Void
    
    struct Options {
        var ignoreRecentlySentPhotoMetadata = false
    }
    
    let userId: User.ID
    var tag: LoadUserTag = String(CFAbsoluteTimeGetCurrent())
    var options = Options()
    let callback: OtherUserFetchCallback
    
    init(userId: User.ID, callback: OtherUserFetchCallback) {
        self.userId = userId
        self.callback = callback
    }
}

final class Callbacks {
    
    typealias CallbacksWithTag = Dictionary<LoadUserTag, OtherUserFetchCallback>
    typealias CallbacksWithUser = Dictionary<User.ID, CallbacksWithTag>
    
    private let emptyCallbacksWithTag = CallbacksWithTag()
    private var callbacksWithUser = CallbacksWithUser()
    
    final func addWithRequest(request: OtherUserFetchRequest) {
        if callbacksWithUser[request.userId] == nil {
            callbacksWithUser[request.userId] = CallbacksWithTag()
        }
        callbacksWithUser[request.userId]![request.tag] = request.callback
    }
    
    final func containsUserId(userId: User.ID) -> Bool {
        return callbacksWithUser[userId] != nil
    }
    
    final func cancelWithTag(tag: LoadUserTag) {
        for (_, var callbackWithTag) in callbacksWithUser {
            callbackWithTag.removeValueForKey(tag)
        }
    }
    
    final func notifyOnPrepareWithUserId(userId: User.ID, user: OtherUser) {
        iterate(userId) { callback in
            callback.prepareCallback(otherUser: user)
        }
    }
    
    final func notifyOnSuccessWithUserId(userId: User.ID, user: OtherUser) {
        iterate(userId) { callback in
            callback.successCallback(otherUser: user)
        }
        removeWithUserId(userId)
    }
    
    final func notifyOnFailureWithUserId(userId: User.ID) {
        iterate(userId) { callback in
            callback.failureCallback(userId: userId)
        }
        removeWithUserId(userId)
    }
    
    private final func iterate(userId: User.ID, block: (callback: OtherUserFetchCallback) -> ()) {
        for (_, callback) in callbackWithTagWithUserId(userId) {
            block(callback: callback)
        }
    }
    
    private final func callbackWithTagWithUserId(userId: User.ID) -> CallbacksWithTag {
        return callbacksWithUser[userId] ?? emptyCallbacksWithTag
    }
    
    private final func removeWithUserId(userId: User.ID) {
        callbacksWithUser.removeValueForKey(userId)
    }
}

struct OtherUserFetchCallback {
    
    typealias PrepareCallback = (otherUser: OtherUser) -> Void
    typealias SuccessCallback = (otherUser: OtherUser) -> Void
    typealias FailureCallback = (userId: User.ID) -> Void
    
    let prepareCallback: PrepareCallback
    let successCallback: SuccessCallback
    let failureCallback: FailureCallback
}
