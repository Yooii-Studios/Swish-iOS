//
//  PhotoDetailViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 15..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var photoId: Photo.ID = Photo.InvalidId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initImageView()
        
        // TODO: Done 버튼 x 표시로 변경
        // TODO: 아래쪽 저장, 공유 버튼 구현
    }
    
    private func initImageView() {
        if let photo = SwishDatabase.photoWithId(photoId) {
            photo.loadImage { image in
                self.imageView.image = image
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func backButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
