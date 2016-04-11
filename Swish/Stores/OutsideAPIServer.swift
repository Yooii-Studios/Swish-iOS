//
//  OutsideAPIServer.swift
//  Swish
//
//  Created by YunSeungyong on 2016. 2. 26..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CountryInfoResponse {
    let name: String
    let code: String
}

final class OutsideAPIServer {
    
    class func requestCountryInfo(onSuccess onSuccess: CountryInfoResponse -> Void, onFail: FailCallback) {
            let url = "http://ip-api.com/json"
            let parser = { (resultJson: JSON) -> CountryInfoResponse in return countryInfoFrom(resultJson) }
            let httpRequest = HttpRequest<CountryInfoResponse>(method: .GET, url: url,
                parser: parser, onSuccess: onSuccess, onFail: onFail)
            httpRequest.useAuthHeader = false
            
            SwishServer.requestWith(httpRequest)
    }
    
    private class func countryInfoFrom(resultJson: JSON) -> CountryInfoResponse {
        return CountryInfoResponse(name: resultJson["country"].stringValue, code: resultJson["countryCode"].stringValue)
    }
}
