//
//  StickerServer.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 9..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftyJSON

final class StickerServer {
    
    private static let BaseStickerUrl = SwishServer.Host + "/stickers"
    
    class func stickerWith(key: String, onSuccess: (stickerUrl: String) -> (), onFail: FailCallback) {
            let params = stickerParamWith(key)
            let parser = { (resultJson: JSON) -> String in return stickerFileUrlFrom(resultJson) }
            let httpRequest = HttpRequest<String>(method: .GET, url: BaseStickerUrl, parameters: params, parser: parser, onSuccess: onSuccess, onFail: onFail)
            
            SwishServer.requestWith(httpRequest)
    }
    
    // MARK: - Params
    
    private class func stickerParamWith(key: String) -> Param {
        return [ "sticker_name": key ]
    }
    
    // MARK: - Parsers
    
    private class func stickerFileUrlFrom(resultJson: JSON) -> String {
        return resultJson["sticker_zipfile_url"].stringValue
    }
}
