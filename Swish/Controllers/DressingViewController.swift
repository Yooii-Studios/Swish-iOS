//
//  DressingViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 11..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit

final class DressingViewController: UIViewController, SegueHandlerType {
    
    // MARK: SegueHandlerType
    
    enum SegueIdentifier: String {
        case UnwindToMain
        case ShowShareResult
    }
    
    final var image: UIImage!
    
    @IBOutlet var testImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        testImageView?.image = image
    }

    // TODO: 추후 unwindSegue를 삭제하고 되돌릴 가능성이 있기에 놔둠
//    @IBAction func cancelButtonDidTap(sender: UIBarButtonItem) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowShareResult:
            // TODO: 여기서부터 초기화는 동현이 추후에 해줄 것
            //            let destinationController = segue.destinationViewController as! ShareResultController
            //            destinationController.image = image
            print("showShareResult")
            
        case .UnwindToMain:
            // TODO: 돌아가기 전 필요한 처리가 있다면 해줄 것
            print("UnwindToMain")
            
        }
    }

    @IBAction func shareButtonDidTap(sender: AnyObject) {
        // TODO: 나중에 사진 보내기 애니메이션 구현할 것

        // TODO: 동현이 넣은 샘플 코드. 나중에 확인 후 참고해서 로직 구현
//        let photo = Photo.create(message: "", departLocation: LocationManager.dummyLocation)
//        let image = UIImage(contentsOfFile: FileHelper.filePathWithName("qwerasdf.png"))!
//        PhotoExchanger.exchange(photo, image: image, departLocation: LocationManager.dummyLocation,
//            completion: { (photos) -> Void in
//                print("PhotoExchanger complete: \(photos)")
//        })
        
        // 애니메이션 없이 동현이 사진 보내기 로직을 구현하고, 
        // 콜백에서 여기에 미리 만들어둔 ShareResultViewController
        // 와의 연결 로직을 옮겨 준다.
        performSegueWithIdentifier(.ShowShareResult, sender: self)
    }
}
