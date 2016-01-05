//
//  SentPhotoDetailViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 26..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class SentPhotoDetailViewController: UIViewController, PhotoActionType {
    
    // Photo Views
    @IBOutlet weak var photoCardView: PhotoCardView!
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

        setUpPhotoCardView()
        setUpStatusViews()
        setUpPhotoActionView()
    }
    
    // MARK: - Init
    
    private func setUpPhotoCardView() {
        photoCardView.setUpWithPhoto(photo)
    }
    
    private func setUpStatusViews() {
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
    
    // MARK: - Debug
    // TODO: 사진 상태를 업데이트받는 상황을 테스트, setUpStatusView()는 추후 뷰를 리팩토링 하는 방식으로 중복 제거 필요
    @IBAction func waitingButtonDidTap(sender: AnyObject) {
        SwishDatabase.updatePhotoState(photo.id, photoState: .Waiting)
        setUpStatusViews()
    }
    
    @IBAction func deliveredButtonDidTap(sender: AnyObject) {
        SwishDatabase.updatePhotoState(photo.id, photoState: .Delivered)
        setUpStatusViews()
    }
    
    @IBAction func likeDislikeButtonDidTap(sender: AnyObject) {
        if photo.photoState == .Liked {
            SwishDatabase.updatePhotoState(photo.id, photoState: .Disliked)
        } else {
            SwishDatabase.updatePhotoState(photo.id, photoState: .Liked)
        }
        setUpStatusViews()
    }
    
    // TODO: 채팅 메시지 증가 테스트. 추후 삭제 필요
    @IBAction func increaseChatCountButtonDidTap(sender: AnyObject) {
        SwishDatabase.increaseUnreadChatCount(photo.id)
    }
}
