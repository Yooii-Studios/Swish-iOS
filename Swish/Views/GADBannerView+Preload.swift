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
            
            // 
             adRequest.testDevices = [kGADSimulatorID]
            
            let bannerView = GADBannerView(adSize: adSize)
            bannerView.adUnitID = unitId
            bannerView.rootViewController = rootViewController
            bannerView.loadRequest(adRequest)
            
            return bannerView
    }
}
