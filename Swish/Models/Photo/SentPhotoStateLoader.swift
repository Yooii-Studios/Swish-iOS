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
    
    final func execute(onSuccess: SuccessCallback, onFailure: FailureCallback) {
        cancel()
        executeFetch(onSuccess, onFailure: onFailure)
    }
    
    func cancel() {
        PhotoServer.cancelFetchPhotoState()
    }
    
    // MARK: - Core functions
    
    private func executeFetch(onSuccess: SuccessCallback, onFailure: FailureCallback) {
        PhotoServer.photoStatesWith(MeManager.me().id,
            onSuccess: { (serverPhotoState) -> () in
                onSuccess(updatedPhotoIds: self.parseUpdatedPhotoIds(serverPhotoState))
            },
            onFail: { (error) -> () in
                onFailure()
        })
    }
    
    // MARK: - Helper functions
    
    private func parseUpdatedPhotoIds(serverPhotoState: Array<ServerPhotoState>) -> Set<Photo.ID> {
        var updatedPhotoIds = Set<Photo.ID>()
        for serverPhotoState in serverPhotoState {
            SwishDatabase.updatePhoto(serverPhotoState.photoId) {
                let stateChanged = $0.photoState != serverPhotoState.state
                let locationUpdated = serverPhotoState.deliveredLocation != nil
                
                if stateChanged || locationUpdated {
                    updatedPhotoIds.insert(serverPhotoState.photoId)
                }
                if stateChanged {
                    $0.photoState = serverPhotoState.state
                }
                if let deliveredLocation = serverPhotoState.deliveredLocation {
                    $0.arrivedLocation = deliveredLocation
                }
            }
        }
        return updatedPhotoIds
    }
}
