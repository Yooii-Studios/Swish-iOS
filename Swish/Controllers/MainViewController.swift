//
//  ViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import SnapKit
import CTAssetsPickerController

final class MainViewController: UIViewController, UINavigationControllerDelegate, PhotoPickable,
    ReceivedPhotoDisplayable, WingsObservable {

    @IBOutlet weak var photoCardView: PhotoCardView!
    @IBOutlet weak var wingsCounterView: WingsCounterView!
    
    var currentDisplayingPhoto: Photo?
    var currentDisplayingPhotoIndex: Int?
    
    final var photoPickerHandler: PhotoPickerHandler?
    
    var wingsObserverTag: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 네비게이션 로고 커스터마이징 필요
        
        photoPickerHandler = PhotoPickerHandler() { image in
            self.showDressingViewContoller(image)
        }
        
        registerRemoteNotification()
        
        initReceivedPhotoDisplayable()
        initPhotoCardView()
        
        MeManager.fetchCurrentCountryWithIP()
    }
    
    private func registerRemoteNotification() {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    private func initPhotoCardView() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: "photoCardViewDidTap:")
        photoCardView.addGestureRecognizer(singleTapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshReceivedPhotoDisplayable()
        observeWingsChange()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopObservingWingsChange()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func pickPhotoButtonDidTap(sender: UIButton!) {
        presentPhotoPickerContoller()
    }
    
    // TODO: 드레싱, 공유 결과에서 한번에 돌아오는 로직. 구분 될 필요가 없어서 공통으로 사용하게 했는데 추후 필요하면 나누어서 쓸 것
    @IBAction func unwindFromViewController(segue: UIStoryboardSegue) {
        print("unwindFromViewController")
    }
    
    final func showDressingViewContoller(image: UIImage) {
        let storyboard = UIStoryboard(name: "Dressing", bundle: nil)
        let navigationViewController =
        storyboard.instantiateViewControllerWithIdentifier("dressingNaviViewController") as! UINavigationController
        let dressingViewController = navigationViewController.topViewController as! DressingViewController
        dressingViewController.image = image
        
        // TODO: present 방식은 whose view is not in the window hierarchy! 문제 해결 필요
        // 둘 중 한 가지 방식으로 해결해야 하는데, show는 completion 핸들러가 없어서 곤란. Picker 화면에서 바로 드레싱을 띄우고 싶음
//        presentViewController(navigationViewController, animated: true, completion: nil)
        showViewController(navigationViewController, sender: self)
    }
    
    // MARK: - Received Photos
    
    final func displayReceivedPhoto(photo: Photo?) {
        if let photo = photo {
            photoCardView.setUpWithPhoto(photo)
        } else {
            // TODO: 첫 시작 시 사진이 없을 경우 환영 메시지 표시 추가 구현 필요
        }
    }
    
    func photoCardViewDidTap(sender: AnyObject?) {
        showNextPhoto()
    }
    
    // MARK: - Wings
    
    func wingsCountDidChange(wingCount: Int) {
        wingsCounterView.refreshWingsCount(wingCount)
    }
    
    func wingsTimeLeftToChargeChange(timeLeftToCharge: Int?) {
        wingsCounterView.refreshLeftTime(timeLeftToCharge)
    }
}
