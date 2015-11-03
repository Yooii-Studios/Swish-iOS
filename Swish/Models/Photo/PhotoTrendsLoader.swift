//
//  TrendingPhoto.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 27..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

final class PhotoTrends: Object {
    
    let trendingPhotos = List<TrendingPhoto>()
    dynamic var fetchedTimeMilli = NSTimeInterval.NaN
    
    var country: PhotoTrendsCountry {
        get {
            return PhotoTrendsCountry(name: countryName)
        }
        set {
            countryName = newValue.name
        }
    }
    
    // MARK: - Initializer
    
    private convenience init(countryName: String, trendingPhotos: [TrendingPhoto]) {
        self.init()
        self.countryName = countryName
        self.trendingPhotos.appendContentsOf(trendingPhotos)
        self.fetchedTimeMilli = NSDate().timeIntervalSince1970
    }
    
    // MARK: - Helper functions
    
    final class func create(countryName: String, trendingPhotos: [TrendingPhoto]) -> PhotoTrends {
        return PhotoTrends(countryName: countryName, trendingPhotos: trendingPhotos)
    }
    
    // MARK: - Realm support
    
    private dynamic var countryName = ""
    
    override static func ignoredProperties() -> [String] {
        return ["country"]
    }
}

// TODO: 추후 Rleam에서 지원 + Photo 클래스와 함께 다뤄야 할 경우 PhotoProtocol에 id, message, departLocation 넣어서 추출 필요
final class TrendingPhoto: Object {
    
    dynamic var id: Photo.ID = InvalidPhotoId
    dynamic var message = InvalidPhotoMessage
    dynamic var imageUrl = ""
    var departLocation: CLLocation {
        get {
            return CLLocation(latitude: departLatitude, longitude: departLongitude)
        }
        set {
            departLatitude = newValue.coordinate.latitude
            departLongitude = newValue.coordinate.longitude
        }
    }
    
    // backlink
    var owner: User {
        return PhotoHelper.senderWithTrendingPhoto(self)
    }
    
    private dynamic var departLatitude = CLLocationDegrees.NaN
    private dynamic var departLongitude = CLLocationDegrees.NaN
    
    // MARK: - Initializer
    
    private convenience init(id: Photo.ID) {
        self.init()
        self.id = id
    }
    
    private convenience init(intId: Int) {
        self.init(id: Photo.ID(intId))
    }
    
    // MARK: - Helper functions
    
    final class func create(id: Photo.ID, message: String, departLocation: CLLocation, imageUrl: String) -> TrendingPhoto {
        let trendingPhoto = TrendingPhoto(id: id)
        trendingPhoto.message = message
        trendingPhoto.departLocation = departLocation
        trendingPhoto.imageUrl = imageUrl
        return trendingPhoto
    }
    
    // MARK: - Realm support
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["departLocation"]
    }
}

struct PhotoTrendsCountry {
    
    let name: String
}

final class PhotoTrendsLoader {
    
    typealias Callback = (photoTrends: PhotoTrends?) -> Void
    
    final class func load(callback: Callback) {
        if let cachedPhotoTrends = cachedPhotoTrends() {
            print("PhotoTrends cache hit.")
            callback(photoTrends: cachedPhotoTrends)
        } else {
            fetchFromServer(callback)
        }
    }
    
    final class func cachedPhotoTrends() -> PhotoTrends? {
        if let photoTrends = SwishDatabase.photoTrends() where
            NSCalendar.currentCalendar().isDateInToday(NSDate(timeIntervalSince1970: photoTrends.fetchedTimeMilli)) {
                return photoTrends
        } else {
            return nil
        }
    }
    
    final class func fetchFromServer(callback: Callback) {
        PhotoServer.cancelFetchPhotoTrends()
        PhotoServer.photoTrendsResult({ (photoTrendsResult) -> Void in
            handleResult(photoTrendsResult, callback: callback)
            }, onFail: {(error) -> Void in
                print("\(error)")
                callback(photoTrends: nil)
        })
    }
    
    final class func handleResult(photoTrendsResult: PhotoTrendsResult, callback: Callback) {
        SwishDatabase.deleteAllPhotoTrends()
        
        var trendingPhotos = [TrendingPhoto]()
        convertPhotoTrendsResultToPhotoTrends(photoTrendsResult) { (trendingPhoto, owner) -> Void in
            trendingPhotos.append(trendingPhoto)
            
            SwishDatabase.saveOtherUser(owner)
            SwishDatabase.saveTrendingPhoto(owner, trendingPhoto: trendingPhoto)
        }
        let photoTrends = PhotoTrends.create(photoTrendsResult.countryName, trendingPhotos: trendingPhotos)
        SwishDatabase.savePhotoTrends(photoTrends)
        callback(photoTrends: photoTrends)
    }
    
    // MARK: - Helper functions
    
    final class func convertPhotoTrendsResultToPhotoTrends(photoTrendsResult: PhotoTrendsResult,
        _ handler: (trendingPhoto: TrendingPhoto, owner: OtherUser) -> Void) {
            for trendingPhotoResult in photoTrendsResult.trendingPhotoResults {
                let photo = trendingPhotoResult.photo
                let trendingPhoto = TrendingPhoto.create(photo.id, message: photo.message,
                    departLocation: photo.departLocation, imageUrl: trendingPhotoResult.imageUrl)
                
                handler(trendingPhoto: trendingPhoto, owner: trendingPhotoResult.owner)
            }
    }
}
