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
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet var exchangeStatusView: UIView!

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
        // TODO: 우선 대충만 구현, 추후 보강 필요
        UIView.animateWithDuration(0.2, delay: 0.3, options: UIViewAnimationOptions(),
            animations: {
                self.testImageView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.textField.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }, completion: { isSuccessful in
                UIView.animateWithDuration(0.3,
                    animations: {
                        self.testImageView.transform = CGAffineTransformMakeScale(0.001, 0.001)
                        self.textField.transform = CGAffineTransformMakeScale(0.001, 0.001)
                        self.testImageView.alpha = 0
                        self.textField.alpha = 0
                    }, completion: { isSuccessful in
                        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear,
                            animations: {
                                if let navigationBar = self.navigationController?.navigationBar {
                                    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
                                    navigationBar.frame.origin.y -= (navigationBar.frame.height + statusBarHeight)
                                }
                                
                                // TODO: 애드몹 높이를 뺀 값에서 버튼이 적당히 중앙에 맞게 높이를 맞추어줄 것
                                var buttonFrame = self.shareButton.frame
                                buttonFrame.origin.y -= 400
                                self.shareButton.frame = buttonFrame
                            }, completion: { isSuccessful in
                                self.view.addSubview(self.exchangeStatusView)
                                self.exchangeStatusView.snp_makeConstraints { make in
                                    make.leading.equalTo(self.view)
                                    make.trailing.equalTo(self.view)
                                    make.top.equalTo(self.shareButton.snp_bottom).offset(30)
                                }
                                
                                // TODO: 추후 전송 중 애니메이션 구현 필요
//                                self.performSegueWithIdentifier(.ShowShareResult, sender: self)
                        })
                })
        })
        
        // TODO: 동현이 넣은 샘플 코드. 나중에 확인 후 참고해서 로직 구현
        //        let photo = Photo.create(message: "", departLocation: LocationManager.dummyLocation)
        //        let image = UIImage(contentsOfFile: FileHelper.filePathWithName("qwerasdf.png"))!
        //        PhotoExchanger.exchange(photo, image: image, departLocation: LocationManager.dummyLocation,
        //            completion: { (photos) -> Void in
        //                print("PhotoExchanger complete: \(photos)")
        //        })
        
        // TODO:
        // 애니메이션 없이 동현이 사진 보내기 로직을 구현하고,
        // 콜백에서 여기에 미리 만들어둔 ShareResultViewController
        // 와의 연결 로직을 옮겨 준다.
    }
}
