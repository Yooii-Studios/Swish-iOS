//
//  GADBannerView+Preload.swift
//  Swish
//
//  Created by 정동현 on 2015. 11. 2..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation

extension GADBannerView {
    
    class func preloadedMediumAdViewWithUnitId(unitId: String, rootViewController: UIViewController,
        adSize: GADAdSize = kGADAdSizeMediumRectangle) -> GADBannerView {
            let adRequest = GADRequest()
            
            // 시뮬레이터에서만 테스트 광고, 실제 디바이스에서는 광고 정상 출력
             adRequest.testDevices = [kGADSimulatorID]
            
            let bannerView = GADBannerView(adSize: adSize)
            bannerView.adUnitID = unitId
            bannerView.rootViewController = rootViewController
            bannerView.loadRequest(adRequest)
            
            return bannerView
    }
}
