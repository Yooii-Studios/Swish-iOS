//
//  ImageDownloader+DownloadImage.swift
//  Swish
//
//  Created by 정동현 on 2015. 12. 2..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

extension ImageDownloader {
    
    class func downloadImage(URLString: String, completion: UIImage? -> Void) {
        let URLRequest = NSURLRequest(URL: NSURL(string: URLString)!)
        
        ImageDownloaderHolder.instance.imageDownloader.downloadImage(URLRequest: URLRequest) { response in
            completion(response.result.value)
        }
    }
}

private final class ImageDownloaderHolder {
    
    // MARK: - Singleton
    
    private struct Instance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: ImageDownloaderHolder?
    }
    
    static var instance: ImageDownloaderHolder {
        get {
            dispatch_once(&Instance.dispatchToken) {
                Instance.instance = ImageDownloaderHolder()
            }
            return Instance.instance!
        }
    }
    
    final var imageDownloader: ImageDownloader!
    
    // MARK: - Initializers
    
    private init() {
        imageDownloader = ImageDownloader()
    }
}
