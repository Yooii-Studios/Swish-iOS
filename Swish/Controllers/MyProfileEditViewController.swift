//
//  MyProfileEditViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 1. 7..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import AlamofireImage

class MyProfileEditViewController: UIViewController, PhotoPickable {

    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    
    final var photoPickerHandler: PhotoPickerHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: 로컬라이징 필요
        self.title = "Edit Profile"
        // TODO: ic_profile_delete@2x, ic_my_profile_change_photo@2x 은실 작업 실수로 내가 추후 아트 만들어서 추가할 것
        initUI()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            // "Back button pressed"
            print("willMoveToParentViewController")
        }
    }
    
    private func initUI() {
        let me = MeManager.me()
        
        ImageDownloader.downloadImage(me.profileUrl) { image in
            if let image = image {
                self.profileImageButton.setImage(image, forState: .Normal)
            }
        }
        
        // TODO: 각 텍스트 필드의 길이 관련 예외처리 필요. 특히 닉네임
        nameTextField.text = me.name
        aboutTextField.text = me.about
    }

    @IBAction func changePhotoButtonDidTap(sender: AnyObject) {
        if photoPickerHandler == nil {
            photoPickerHandler = PhotoPickerHandler() { image in
                self.profileImageButton.setImage(image, forState: .Normal)
                MeManager.updateMyProfileImage(image, onSuccess: { profileImageUrl in
                    // 캐시에 미리 한 번 저장을 해 두기 위해서 읽기만 해 놓고 따로 UI변경은 하지 않음
                    ImageDownloader.downloadImage(profileImageUrl, completion: { image in })
                })
            }
        }
        presentPhotoPickerControllerModally()
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
