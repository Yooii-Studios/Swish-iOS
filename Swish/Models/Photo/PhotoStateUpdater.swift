//
//  PhotoStateUpdater.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 22..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

private typealias Updates = Dictionary<Photo.ID, PhotoStateUpdateInfo>
    
final class PhotoStateUpdater {
    
    private let lockingQueue = dispatch_queue_create("com.yooiistudios.swish.photostateupdater", nil)
    private var pendingUpdates = Updates()
    private var executingUpdates = Updates()
    
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
        if pendingUpdates[request.photoId] != nil {
            pendingUpdates[request.photoId]!.targetState = request.state
            SwishDatabase.updatePhotoState(request.photoId, photoState: request.state)
        }
    }
    
    private final func createPendingUpdateInfoEntryWithRequest(request: PhotoStateUpdateRequest) {
        let previousPhotoState = SwishDatabase.photoWithId(request.photoId)!.photoState
        pendingUpdates[request.photoId] = PhotoStateUpdateInfo(request: request, previousPhotoState: previousPhotoState)
        SwishDatabase.updatePhotoState(request.photoId, photoState: request.state)
    }
    
    private final func executeUpdate(updateInfo: PhotoStateUpdateInfo) {
        PhotoServer.updatePhotoState(updateInfo.photoId, state: updateInfo.targetState,
            onSuccess: { _ in
            }, onFail: { _ in
                SwishDatabase.updatePhotoState(updateInfo.photoId, photoState: updateInfo.previousPhotoState)
        })
        executingUpdates[updateInfo.photoId] = updateInfo
    }
    
    private final func cancelExecutingUpdate(updateInfo: PhotoStateUpdateInfo) {
        if let prevUpdateInfo = executingUpdates.removeValueForKey(updateInfo.photoId) {
            PhotoServer.cancelUpdatePhotoStateWithPhotoId(prevUpdateInfo.photoId)
            print("cancelExecutingUpdate: \(prevUpdateInfo.photoId)")
        }
    }
}

struct PhotoStateUpdateRequest {
    let photoId: Photo.ID
    let state: PhotoState
}

private struct PhotoStateUpdateInfo {
    
    let photoId: Photo.ID
    var previousPhotoState: PhotoState
    var targetState: PhotoState
    
    init(request: PhotoStateUpdateRequest, previousPhotoState: PhotoState) {
        self.photoId = request.photoId
        self.previousPhotoState = previousPhotoState
        self.targetState = request.state
    }
}
