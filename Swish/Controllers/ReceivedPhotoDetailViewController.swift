//
//  ReceivedPhotoDetailViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 12. 16..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import AlamofireImage

class ReceivedPhotoDetailViewController: UIViewController, PhotoActionType, PhotoVoteType {

    // TODO: 우성이 protocol extension으로 만들던지, 커스텀뷰로 만들던지 중복을 줄일 필요가 있어 보임
    // Photo
    @IBOutlet weak var photoCardView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var photoActionView: PhotoActionView!
    @IBOutlet weak var photoVoteView: PhotoVoteView!
    
    final var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initPhotoCardView()
        setUpPhotoActionView()
        setUpPhotoVoteView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUnreadChatCount()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        updatePhotoState()
    }
    
    // MARK: - Init
    
    private func initPhotoCardView() {
        initPhotoImage()
        initUserViews()
        initDistanceLabel()
    }
    
    private func initPhotoImage() {
        photo.loadImage { image in
            self.photoImageView.image = image
        }
    }
    
    private func initUserViews() {
        ImageDownloader.downloadImage(photo.sender.profileUrl) { image in
            if let image = image {
                self.profileImageView.image = image
            }
        }
        userIdLabel.text = photo.sender.name
        messageLabel.text = photo.message
    }
    
    private func initDistanceLabel() {
        distanceLabel.text = photo.deliveredDistanceString
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
    
    // MARK: - PhotoActionType 
    
    func mapButtonDidTap(sender: AnyObject) {
        print("mapButtonDidTap")
        showMapViewController()
    }
    
    func chatButtonDidTap(sender: AnyObject) {
        print("chatButtonDidTap")
        showChatDialog()
    }
}
