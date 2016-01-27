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

private struct _ImageDownloader {
    static var dispatchToken: dispatch_once_t = 0
    static var instance: ImageDownloader?
}

private var imageDownloaderInstance: ImageDownloader {
    dispatch_once(&_ImageDownloader.dispatchToken) {
        _ImageDownloader.instance = ImageDownloader()
    }
    return _ImageDownloader.instance!
}

extension ImageDownloader {
    
    class func downloadImage(URLString: String, completion: (UIImage? -> Void)? = nil) {
        let URLRequest = NSURLRequest(URL: NSURL(string: URLString)!)
        
        imageDownloaderInstance.downloadImage(URLRequest: URLRequest) { response in
            completion?(response.result.value)
        }
    }
}
