//
//  SentPhotoStateFetcher.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

final class SentPhotoStateLoader {
    
    typealias SuccessCallback = (updatedPhotoIds: Set<Photo.ID>) -> Void
    typealias FailureCallback = () -> Void
    
    // MARK: - Singleton
    
    private struct Instance {
        
        static var dispatchToken: dispatch_once_t = 0
        static var instance: SentPhotoStateLoader?
    }
    
    static var instance: SentPhotoStateLoader {
        get {
            dispatch_once(&Instance.dispatchToken) {
                Instance.instance = SentPhotoStateLoader()
            }
            return Instance.instance!
        }
    }
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Services
    
    final func execute(onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil) {
        cancel()
        executeFetch(onSuccess, onFailure: onFailure)
    }
    
    func cancel() {
        PhotoServer.cancelFetchPhotoState()
    }
    
    // MARK: - Core functions
    
    private func executeFetch(onSuccess: SuccessCallback?, onFailure: FailureCallback?) {
        PhotoServer.photoStatesWith(MeManager.me().id,
            onSuccess: { (serverPhotoState) -> () in
                let updatedPhotoIds = self.parseUpdatedPhotoIds(serverPhotoState)
                if let onSuccess = onSuccess {
                    onSuccess(updatedPhotoIds: updatedPhotoIds)
                }
            },
            onFail: { (error) -> () in
                if let onFailure = onFailure {
                    onFailure()
                }
            }
        )
    }
    
    // MARK: - Helper functions
    
    private func parseUpdatedPhotoIds(serverPhotoState: Array<ServerPhotoState>) -> Set<Photo.ID> {
        var updatedPhotoIds = Set<Photo.ID>()
        for serverPhotoState in serverPhotoState {
            SwishDatabase.updatePhoto(serverPhotoState.photoId) {
                if $0.photoState != serverPhotoState.state {
                    $0.photoState = serverPhotoState.state
                    updatedPhotoIds.insert(serverPhotoState.photoId)
                }
                if let receivedUserId = serverPhotoState.receivedUserId {
                    $0.receivedUserId = receivedUserId
                }
                if let deliveredLocation = serverPhotoState.deliveredLocation {
                    $0.arrivedLocation = deliveredLocation
                }
            }
        }
        return updatedPhotoIds
    }
}
