//
//  OutsideAPIServer.swift
//  Swish
//
//  Created by YunSeungyong on 2016. 2. 26..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CountryInfo {
    let code: String
    let name: String
}

final class OutsideAPIServer {
    
    class func requestCountryInfo(onSuccess: (countryInfo: CountryInfo) -> (), onFail: FailCallback) {
            let url = "http://ip-api.com/json"
            let parser = { (resultJson: JSON) -> CountryInfo in return countryInfoFrom(resultJson) }
            let httpRequest = HttpRequest<CountryInfo>(method: .GET, url: url,
                parser: parser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.useAuthHeader = false
            
            SwishServer.requestWith(httpRequest)
    }
    
    private class func countryInfoFrom(resultJson: JSON) -> CountryInfo {
        return CountryInfo(code: resultJson["countryCode"].stringValue, name: resultJson["country"].stringValue)
    }
}
