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

final class MainViewController: UIViewController, UINavigationControllerDelegate, PhotoPickable, ReceivedPhotoDisplayable {

    // TODO: 우성이 protocol extension으로 만들던지, 커스텀뷰로 만들던지 중복을 줄일 필요가 있어 보임
    // Photo
    @IBOutlet weak var photoCardView: PhotoCardView!
    
    var currentDisplayingPhoto: Photo?
    var currentDisplayingPhotoIndex: Int?
    
    final var photoPickerHandler: PhotoPickerHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoPickerHandler = PhotoPickerHandler() { image in
            self.showDressingViewContoller(image)
        }
        
        registerRemoteNotification()
        
        initReceivedPhotoDisplayable()
        initPhotoCardView()
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
        refreshReceivedPhotoDisplayable()
    }
    
    // FIXME: 메서드 이름 변경하고 Photo Trends가 될 예정
    @IBAction func cameraButtonDidTap(sender: UIButton!) {
        /*
        NSLog("cameraButtonDidTap")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            imagePickerController.allowsEditing = false
            showViewController(imagePickerController, sender: self)
        } else {
            NSLog("cameraNotAvailable")
        }
        */
    }
    
    @IBAction func pickPhotoButtonDidTap(sender: UIButton!) {
        showPhotoPickerContoller()
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
            // TODO: 사진이 없을 경우 환영 메시지 표시 추가 구현 필요
        }
    }
    
    func photoCardViewDidTap(sender: AnyObject?) {
        showNextPhoto()
    }
}
