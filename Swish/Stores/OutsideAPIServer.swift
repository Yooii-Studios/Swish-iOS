//
//  OutsideAPIServer.swift
//  Swish
//
//  Created by YunSeungyong on 2016. 2. 26..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftyJSON


final class OutsideAPIServer {
    
    typealias CountryInfoTup = (name: String, code: String)
    
    class func requestCountryInfo(onSuccess: (countryInfo: CountryInfoTup) -> (), onFail: FailCallback) {
            let url = "http://ip-api.com/json"
            let parser = { (resultJson: JSON) -> CountryInfoTup in return countryInfoFrom(resultJson) }
            let httpRequest = HttpRequest<CountryInfoTup>(method: .GET, url: url,
                parser: parser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.useAuthHeader = false
            
            SwishServer.requestWith(httpRequest)
    }
    
    private class func countryInfoFrom(resultJson: JSON) -> CountryInfoTup {
        return (name: resultJson["country"].stringValue, code: resultJson["countryCode"].stringValue)
    }
}
