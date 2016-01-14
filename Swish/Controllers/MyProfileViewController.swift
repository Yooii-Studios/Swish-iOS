//
//  MyProfileViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 1. 6..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import AlamofireImage

class MyProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var sentPhotoCountLabel: UILabel!
    @IBOutlet weak var likedPhotoCountLabel: UILabel!
    @IBOutlet weak var dislikedPhotoCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    private func initUI() {
        initUserImageView()
        initUserLabels()
        initUserActivityView()
    }
    
    private func initUserImageView() {
        
        MeObserver.observeProfileUrl(self, handler: { profileUrl in
            ImageDownloader.downloadImage(profileUrl) { [weak self] image in
                if let image = image {
                    self?.profileImageView.image = image
                }
            }
        })
    }
    
    private func initUserLabels() {
        MeObserver.observeName(self, handler: { [unowned self] name in
            self.nameLabel.text = name
        })
        
        MeObserver.observeAbout(self, handler: { [unowned self] about in
            self.aboutLabel.text = about
        })
    }
    
    private func initUserActivityView() {
        setUserActivityRecordsInVisible()
        fetchUserActivityRecords()
    }
    
    private func setUserActivityRecordsInVisible() {
        // 스토리보드에서 미리 alpha = 0을 할 수 있지만 폰트 스타일 조절을 위해 여기에서 처리
        sentPhotoCountLabel.alpha = 0
        likedPhotoCountLabel.alpha = 0
        dislikedPhotoCountLabel.alpha = 0
    }
    
    private func fetchUserActivityRecords() {
        UserServer.activityRecordWith(MeManager.me().id,
            onSuccess: { userActivityRecord in
                self.setUserActivityRecord(userActivityRecord)
            }, onFail: { (error) -> () in
                self.setUserActivityRecord(MeManager.me().userActivityRecord)
        })
    }
    
    private func setUserActivityRecord(userActivityRecord: UserActivityRecord) {
        sentPhotoCountLabel.text = String(userActivityRecord.sentPhotoCount)
        likedPhotoCountLabel.text = String(userActivityRecord.likedPhotoCount)
        dislikedPhotoCountLabel.text = String(userActivityRecord.dislikedPhotoCount)
        
        setUserActivityRecordsVisible()
    }
    
    private func setUserActivityRecordsVisible() {
        sentPhotoCountLabel.alpha = 1
        likedPhotoCountLabel.alpha = 1
        dislikedPhotoCountLabel.alpha = 1
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
