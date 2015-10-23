//
//  PhotoStateUpdater.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 22..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

typealias SuccessCallback = (photoId: Photo.ID, state: PhotoState) -> ()
typealias FailureCallback = (photoId: Photo.ID) -> ()
private typealias Updates = Dictionary<Photo.ID, PhotoStateUpdateInfo>
    
final class PhotoStateUpdater {
    
    private let lockingQueue = dispatch_queue_create("com.yooiistudios.swish.photostateupdater", nil)
    private var pendingUpdates = Updates()
    private var executingUpdates = Updates()
    private var additionalDelegates = [PhotoStateUpdateDelegate]()
    
    // MARK: - Singleton
    
    private struct Instance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: PhotoStateUpdater?
    }
    
    static var instance: PhotoStateUpdater {
        get {
            dispatch_once(&Instance.dispatchToken) {
                Instance.instance = PhotoStateUpdater()
            }
            return Instance.instance!
        }
    }
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Services
    
    final func registerUpdateRequest(request: PhotoStateUpdateRequest) {
        sync {
            if !self.containsPendingRequestWithPhotoId(request.photoId) {
                self.createPendingUpdateInfoEntryWithRequest(request)
            } else {
                self.updatePendingUpdateInfoWithRequest(request)
            }
        }
    }
    
    final func execute() {
        sync {
            for (_, updateInfo) in self.pendingUpdates {
                self.cancelExecutingUpdate(updateInfo)
                self.executeUpdate(updateInfo)
            }
            self.pendingUpdates.removeAll()
        }
    }
    
    final func registerDelegate(delegate: PhotoStateUpdateDelegate) {
        sync {
            if !self.additionalDelegates.contains({ $0 === delegate }) {
                self.additionalDelegates.append(delegate)
            }
        }
    }
    
    final func unregisterDelegate(delegate: PhotoStateUpdateDelegate) {
        sync {
            if let index = self.additionalDelegates.indexOf({ $0 === delegate }) {
                self.additionalDelegates.removeAtIndex(index)
            }
        }
    }
    
    // MARK: - Helper functions
    
    private final func sync(block: () -> Void) {
        dispatch_sync(lockingQueue) {
            block()
        }
    }
    
    private final func containsPendingRequestWithPhotoId(photoId: Photo.ID) -> Bool {
        return pendingUpdates[photoId] != nil
    }
    
    private final func updatePendingUpdateInfoWithRequest(request: PhotoStateUpdateRequest) {
        if var pendingUpdateInfo = pendingUpdates[request.photoId] {
            pendingUpdateInfo.state = request.state
            if let newDelegate = request.delegate
                where !pendingUpdateInfo.delegates.contains({ $0 === newDelegate }) {
                pendingUpdateInfo.delegates.append(newDelegate)
            }
        }
    }
    
    private final func createPendingUpdateInfoEntryWithRequest(request: PhotoStateUpdateRequest) {
        pendingUpdates[request.photoId] = PhotoStateUpdateInfo(request: request)
    }
    
    private final func executeUpdate(updateInfo: PhotoStateUpdateInfo) {
        if let previousPhotoState = SwishDatabase.photoWithId(updateInfo.photoId)?.photoState {
            SwishDatabase.updatePhotoState(updateInfo.photoId, photoState: updateInfo.state)
            PhotoServer.updatePhotoState(updateInfo.photoId, state: updateInfo.state,
                onSuccess: { (result) -> () in
                    self.notifySuccess(updateInfo)
                }, onFail: { (error) -> () in
                    SwishDatabase.updatePhotoState(updateInfo.photoId, photoState: previousPhotoState)
                    self.notifyFailure(updateInfo)
            })
            executingUpdates[updateInfo.photoId] = updateInfo
        }
    }
    
    private final func cancelExecutingUpdate(updateInfo: PhotoStateUpdateInfo) {
        if let prevUpdateInfo = executingUpdates.removeValueForKey(updateInfo.photoId) {
            PhotoServer.cancelUpdatePhotoStateWithPhotoId(prevUpdateInfo.photoId)
            print("cancelExecutingUpdate: \(prevUpdateInfo.photoId)")
        }
    }
    
    private final func notifySuccess(updateInfo: PhotoStateUpdateInfo) {
        let notifyBlock = { (delegate: PhotoStateUpdateDelegate) -> Void in
            delegate.onSuccess(updateInfo.photoId, state: updateInfo.state)
        }
        iterateDelegates(updateInfo, block: notifyBlock)
        iterateAdditionalDelegates(notifyBlock)
    }
    
    private final func notifyFailure(updateInfo: PhotoStateUpdateInfo) {
        let notifyBlock = { (delegate: PhotoStateUpdateDelegate) -> Void in
            delegate.onFailure(updateInfo.photoId)
        }
        iterateDelegates(updateInfo, block: notifyBlock)
        iterateAdditionalDelegates(notifyBlock)
    }
    
    private final func iterateDelegates(updateInfo: PhotoStateUpdateInfo,
        block: (delegate: PhotoStateUpdateDelegate) -> Void) {
            for delegate in updateInfo.delegates {
                block(delegate: delegate)
            }
    }
    
    private final func iterateAdditionalDelegates(block: (delegate: PhotoStateUpdateDelegate) -> Void) {
        for delegate in additionalDelegates {
            block(delegate: delegate)
        }
    }
}

protocol PhotoStateUpdateDelegate: class {
    
    func onSuccess(photoId: Photo.ID, state: PhotoState)
    func onFailure(photoId: Photo.ID)
}

struct PhotoStateUpdateRequest {
    
    let photoId: Photo.ID
    let state: PhotoState
    let delegate: PhotoStateUpdateDelegate?
}

private struct PhotoStateUpdateInfo {
    
    let photoId: Photo.ID
    var state: PhotoState
    var delegates = [PhotoStateUpdateDelegate]()
    
    init(request: PhotoStateUpdateRequest) {
        photoId = request.photoId
        state = request.state
        if let delegate = request.delegate {
            delegates.append(delegate)
        }
    }
}
