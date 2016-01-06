//
//  PhotoStatusView.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 1. 6..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import NibDesignable

@IBDesignable
class PhotoStatusView: NibDesignable {

    // Status
    @IBOutlet weak var statusContentView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusDescriptionLabel: UILabel!
    
    final func setUpWithPhoto(photo: Photo) {
        // TODO: 추후 PhotoStateView로 래핑해줄 것
        statusLabel.text = photo.photoState.sentStateResId
        statusDescriptionLabel.text = photo.photoState.sentStateDescriptionResId
        statusImageView.image = UIImage(named: photo.photoState.sentDetailStateImgResId)
        
        if let userId = photo.receivedUserId where photo.photoState == .Liked {
            // TODO: UI 업데이트
            let callback = OtherUserFetchCallback(
                prepareCallback: { otherUser in
                    print("prepare: \(otherUser.name)")
                }, successCallback: { otherUser in
                    print("success: \(otherUser.name)")
                }, failureCallback: { userId in
                    print("failure: \(userId)")
            })
            
            let fetchRequest = OtherUserFetchRequest(userId: userId, callback: callback)
            OtherUserLoader.instance.loadOtherUserWithRequest(fetchRequest)
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
