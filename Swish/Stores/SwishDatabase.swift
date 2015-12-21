//
//  File.swift
//  RealmTest
//
//  Created by 정동현 on 2015. 9. 3..
//  Copyright (c) 2015년 Yooii Studios. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

final class SwishDatabase {
    
    typealias PhotoFilter = (photo: Photo) -> Bool
    
    static let realm: Realm = try! Realm()
    
    class func migrate() {
        let config = Realm.Configuration(
            // TODO: 출시 전에 버전 0으로 변경하자
            schemaVersion: 34,
            
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: - General
    
    class func object<T: Object>(comparator: (target: T) -> Bool) -> T? {
        for object in objects(T) where comparator(target: object) {
            return object
        }
        return nil
    }
    
    class func objects<T: Object>(type: T.Type) -> Array<T> {
        return SwishDatabase.convertToArray(rawObjects(type))
    }
    
    class func deleteForPrimaryKey<T: Object>(type: T.Type, key: AnyObject) {
        if let object = realm.objectForPrimaryKey(type, key: key) {
            write {
               realm.delete(object)
            }
        }
    }
    
    class func delete<T: Object>(comparator: (target: T) -> Bool) {
        let objects = realm.objects(T)
        for object in objects where comparator(target: object) {
            write {
                // TODO: consider cascading through referencing objects
                realm.delete(object)
            }
            break
        }
    }
    
    class func delete<T: Object>(objects: List<T>) {
        write {
            realm.delete(objects)
        }
    }
    
    class func objectCount<T: Object>(type: T.Type) -> Int {
        return rawObjects(type).count
    }
    
    class func deleteAll() {
        do {
            try realm.write {
                self.realm.deleteAll()
            }
        }
        catch {
            // ignored
        }
    }
    
    class func write(block: (() -> Void)) {
        let _ = try? realm.write(block)
    }
    
    // MARK: - Me
    
    class func me() -> Me {
        // Assume always have Me
        return rawObjects(Me)[0]
    }
    
    class func hasMe() -> Bool {
        return rawObjects(Me).count > 0
    }
    
    class func saveMe(me: Me) {
        write {
            realm.add(me)
        }
    }
    
    class func updateMe(name: String? = nil, about: String? = nil) {
        write {
            let me = self.me()
            me.name = name ?? me.name
            me.about = about ?? me.about
        }
    }
    
    class func updateMyProfileImage(profileImageUrl: String) {
        write {
            let me = self.me()
            me.profileUrl = profileImageUrl
        }
    }
    
    class func updateMyActivityRecord(record: UserActivityRecord) {
        write {
            let me = self.me()
            me.userActivityRecord = record
        }
    }
    
    // MARK: - OtherUser
    
    class func otherUser(id: User.ID) -> OtherUser? {
        let users = rawObjects(OtherUser).filter("id = '\(id)'")
        return users.count > 0 ? users[0] : nil;
    }
    
    class func saveOtherUser(otherUser: OtherUser) {
        write {
            if let prevUser = self.otherUser(otherUser.id) {
                UserHelper.renewOtherUser(prevUser, newUser: otherUser)
            }
            realm.add(otherUser, update: true)
        }
    }
    
    class func deleteOtherUserWhenPossible(user: OtherUser) {
        if user.photos.count == 0 && user.trendingPhotos.count == 0 {
            deleteRecentlySentPhotoUrlsInOtherUser(user)
            write {
                realm.delete(user)
            }
        }
    }
    
    class func deleteRecentlySentPhotoUrlsInOtherUser(user: OtherUser) {
        if let recentlySentPhotoUrls = user.recentlySentPhotoUrls {
            write {
                for photoMetadata in recentlySentPhotoUrls {
                    realm.delete(photoMetadata)
                }
            }
        }
    }
    
    // MARK: - Photos
    
    class func saveSentPhoto(photo: Photo, serverId: Photo.ID) {
        write {
            photo.id = serverId
            me().photos.append(photo)
        }
    }
    
    class func deletePhoto(photoId: Photo.ID) {
        if let photo = photoWithId(photoId) {
            deleteChatMessages(photo.chatMessages)
            deleteForPrimaryKey(Photo.self, key: NSNumber(longLong: photoId))
        }
    }
    
    class func updatePhoto(photoId: Photo.ID, _ update: (photo: Photo) -> ()) {
        let photo = photoWithId(photoId)
        if let photo = photo {
            write {
                update(photo: photo)
            }
        }
    }
    
    class func saveReceivedPhoto(user: OtherUser, photo: Photo) {
        write {
            user.photos.append(photo)
        }
    }
    
    class func photoWithId(id: Photo.ID) -> Photo? {
        let photoCandidates = rawObjects(Photo).filter("id = \(id)")
        if photoCandidates.count > 0 {
            return photoCandidates[0]
        }
        return nil
    }
    
    class func receivedPhotos() -> Array<Photo> {
        let myId = me().id
        return objects {
            return $0.sender.id != myId && $0.photoState != .Disliked
        }.sort { return $0.recentEventTime > $1.recentEventTime }
    }
    
    class func sentPhotos() -> Array<Photo> {
        return me().photos.sort { return $0.recentEventTime > $1.recentEventTime }
    }
    
    // sentPhotos() 메서드와 중복이 있지만 퍼포먼스를 고려해 우선적으로 filter를 적용하기 위해 수정하지 않음
    class func deliveredSentPhotos() -> Array<Photo> {
        return me().photos.filter { $0.photoState != .Waiting }.sort { return $0.recentEventTime > $1.recentEventTime }
    }
    
    class func unreadMessageCount(id: Photo.ID) -> Int {
        return photoWithId(id)?.unreadMessageCount ?? 0
    }
    
    class func markChatRoomOpened(id: Photo.ID) {
        writePhoto(id, block: {
            (photo: Photo) in
            photo.hasOpenedChatRoom = true
        })
    }
    
    class func updateAllChatRead(id: Photo.ID) {
        writePhoto(id, block: {
            (photo: Photo) in
            photo.unreadMessageCount = 0
        })
    }
    
    class func increaseUnreadChatCount(id: Photo.ID) {
        writePhoto(id, block: {
            (photo: Photo) in
            photo.unreadMessageCount += 1
            photo.recentEventTime = CFAbsoluteTimeGetCurrent()
        })
    }
    
    class func updateChatBlocked(photoId: Photo.ID, state: ChatRoomBlockState) {
        writePhoto(photoId, block: {
            (photo: Photo) in
            photo.chatRoomBlockState = state
        })
    }
    
    class func updatePhotoState(id: Photo.ID, photoState: PhotoState) {
        writePhoto(id, block: {
            (photo: Photo) in
            photo.photoState = photoState
        })
    }
    
    class func updatePhotoArrivedLocation(id: Photo.ID, location: CLLocation) {
        writePhoto(id, block: {
            (photo: Photo) in
            photo.arrivedLocation = location
        })
    }
    
    // MARK: - Chat Message
    
    class func saveChatMessage(photoId: Photo.ID, chatMessage: ChatMessage) {
        if let photo = photoWithId(photoId) {
            saveChatMessage(photo, chatMessage: chatMessage)
        }
    }
    
    class func saveChatMessage(photo: Photo, chatMessage: ChatMessage) {
        write {
            photo.chatMessages.append(chatMessage)
            photo.recentEventTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    class func saveChatMessages(photo: Photo, chatMessages: Array<ChatMessage>) {
        write {
            photo.chatMessages.appendContentsOf(chatMessages)
            photo.recentEventTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    class func loadChatMessages(photoId: Photo.ID, startIndex: Int, amount: Int) -> Array<ChatMessage> {
        var result = Array<ChatMessage>()
        
        if let messagesInPhoto = photoWithId(photoId)?.chatMessages {
            let endIndex = startIndex + amount
            let hasInvalidIndexRange = endIndex <= startIndex
                || startIndex >= messagesInPhoto.count
                || endIndex <= 0
            
            let hasValidIndexRange = !hasInvalidIndexRange
            if hasValidIndexRange {
                for idx in max(startIndex, 0)...min(endIndex, messagesInPhoto.count) - 1 {
                    result.append(messagesInPhoto[idx])
                }
            }
        }
        return result
    }
    
    class func deleteChatMessage(victim: ChatMessage) {
        delete { return $0 == victim }
    }
    
    class func deleteChatMessages(victims: List<ChatMessage>) {
        delete(victims)
    }
    
    class func loadUnreadChatMessagesAndMarkAsRead(photoId: Photo.ID) -> Array<ChatMessage> {
        let messages = loadChatMessages(photoId, startIndex: 0, amount: unreadMessageCount(photoId))
        updateAllChatRead(photoId)
        return messages
    }
    
    class func updateChatMessageState(message: ChatMessage, state: ChatMessageSendState) {
        if let chatMessage = object({ (target: ChatMessage) -> Bool in target == message }) {
            write {
                chatMessage.state = state
            }
        }
    }
    
    // MARK: - PhotoTrends
    
    class func savePhotoTrends(photoTrends: PhotoTrends) {
        deleteAllPhotoTrends()
        write {
            realm.add(photoTrends)
        }
    }
    
    class func photoTrends() -> PhotoTrends? {
        let candidates = rawObjects(PhotoTrends)
        return candidates.count > 0 ? candidates[0] : nil
    }
    
    class func deleteAllPhotoTrends() {
        var unnecessaryUserIds = Set<User.ID>()
        write {
            for photoTrends in rawObjects(PhotoTrends) {
                for trendingPhoto in photoTrends.trendingPhotos {
                    unnecessaryUserIds.insert(trendingPhoto.owner.id)
                }
                realm.delete(photoTrends.trendingPhotos)
                realm.delete(photoTrends)
            }
        }
        for unnecessaryUserId in unnecessaryUserIds {
            if let otherUser = otherUser(unnecessaryUserId) {
                deleteOtherUserWhenPossible(otherUser)
            }
        }
    }
    
    class func saveTrendingPhoto(otherUser: OtherUser, trendingPhoto: TrendingPhoto) {
        write {
            otherUser.trendingPhotos.append(trendingPhoto)
        }
    }
    
    // MARK: - Wings
    
    class func updateWingsCapacityAdditive(additive: Int) {
        write {
            wings().capacityAdditive = additive
        }
    }
    
    class func updateWingsPenalty(penaltyCount: Int) {
        write {
            wings().lastPenaltyCount = penaltyCount
        }
    }
    
    class func updateLastWingsCount(count: Int) {
        write {
            wings().lastWingCount = count
        }
    }
    
    class func updateLastWingCountChangedTimestamp(timestamp: NSTimeInterval?) {
        write {
            wings().lastTimestamp = timestamp
        }
    }
    
    class func resetLastWingCountChangedTimestamp() {
        updateLastWingCountChangedTimestamp(nil)
    }
    
    class func wings() -> Wings {
        var wingsCandidates = objects(Wings)
        if wingsCandidates.count > 0 {
            return wingsCandidates[0]
        } else {
            let wings = Wings()
            write({ () -> Void in
                realm.add(wings)
            })
            return wings
        }
    }
    
    // MARK: - Class functions
    
    private class func objects<T: Object>(filter: (object: T) -> Bool) -> Array<T> {
        var resultObjects = Array<T>()
        for object in objects(T) where filter(object: object) {
            resultObjects.append(object)
        }
        
        return resultObjects
    }
    
    private class func rawObjects<T: Object>(type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    private class func writePhoto(id: Photo.ID, block: (Photo) -> Void) {
        if let photo = photoWithId(id) {
            write {
                block(photo)
            }
        }
    }
    
    private class func convertToArray<T: Object>(src: Results<T>) -> Array<T> {
        var results = Array<T>()
        for result in src {
            results.append(result)
        }
        
        return results
    }
}
