//
//  OutsideAPIServer.swift
//  Swish
//
//  Created by YunSeungyong on 2016. 2. 26..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias CountryInfoTuple = (name: String, code: String)

final class OutsideAPIServer {
    
    class func requestCountryInfo(onSuccess onSuccess: (countryInfo: CountryInfoTuple) -> Void, onFail: FailCallback) {
            let url = "http://ip-api.com/json"
            let parser = { (resultJson: JSON) -> CountryInfoTuple in return countryInfoFrom(resultJson) }
            let httpRequest = HttpRequest<CountryInfoTuple>(method: .GET, url: url,
                parser: parser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.useAuthHeader = false
            
            SwishServer.requestWith(httpRequest)
    }
    
    private class func countryInfoFrom(resultJson: JSON) -> CountryInfoTuple {
        return (name: resultJson["country"].stringValue, code: resultJson["countryCode"].stringValue)
    }
}
