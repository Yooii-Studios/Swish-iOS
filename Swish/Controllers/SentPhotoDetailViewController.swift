//
//  SentPhotoDetailViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 26..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class SentPhotoDetailViewController: UIViewController, PhotoActionType {
    
    // TODO: 우성이 PhotoCardView로 커스텀 뷰를 만들어 처리를 해줄 것
    // Photo
    @IBOutlet weak var photoCardView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // Photo Action
    @IBOutlet weak var photoActionView: PhotoActionView!
    
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
        setUpPhotoActionView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUnreadChatCount()
    }
    
    // MARK: - Init
    
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
    
    final func mapButtonDidTap(sender: AnyObject) {
        print("mapButtonDidTap")
        showMapViewController()
    }
    
    final func chatButtonDidTap(sender: AnyObject) {
        print("chatButtonDidTap")
        showChatDialog()
    }
}
