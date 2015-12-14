//
//  SentPhotoDetailViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 26..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class SentPhotoDetailViewController: UIViewController {
    
    // Photo
    @IBOutlet weak var photoCardView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // Status
    @IBOutlet weak var statusContentView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusDescriptionLabel: UILabel!

    final var photo: Photo!
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initPhotoCardView()
        initStatusViews()
        initActionView()
    }
    
    private func initPhotoCardView() {
        photo.loadImage { image in
            self.photoImageView.image = image
        }
        // TODO: 동현에게 유저 프로필 이미지 어떻게 불러오는지 물어보고 처리할 것
        //        profileImageView.image = photo.sender.profileUrl
        
        initUserViews()
        initDistanceLabel()
    }
    
    private func initUserViews() {
        userIdLabel.text = photo.sender.name
        messageLabel.text = photo.message
    }
    
    private func initDistanceLabel() {
        distanceLabel.text = photo.deliveredDistanceString
    }
    
    private func initStatusViews() {
        // TODO: 추후 PhotoStateView로 래핑해줄 것
        statusLabel.text = photo.photoState.sentStateResId
        statusDescriptionLabel.text = photo.photoState.sentStateDescriptionResId
        statusImageView.image = UIImage(named: photo.photoState.sentDetailStateImgResId)
        
        // TODO: Like한 유저 정보를 받을 수 있게 동현이 모델 구현 후 추가해줄 것, 좋아요를 한 유저의 Id를 항상 가지고 있게 구현할 예정
        if photo.photoState == .Liked {
            /*
            let callback = OtherUserFetchCallback(
                prepareCallback: { otherUser in
                    
                }, successCallback: { otherUser in
                    
                }, failureCallback: { userId in
            })
            
            // receiverId 부분을 추후 수정해야 함
            let fetchRequest = OtherUserFetchRequest(userId: , callback: callback)
            OtherUserLoader.instance.loadOtherUserWithRequest(fetchRequest)
            */
        }
    }
    
    private func initActionView() {
        // TODO: 추후 protocol extension으로 구현하고 연동할 것
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func cancelButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
