//
//  DressingViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 11..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import SVProgressHUD

final class DressingViewController: UIViewController, SegueHandlerType, LocationTrackable {
    
    private let AdUnitId = "ca-app-pub-2310680050309555/3617770227"
    
    // SegueHandlerType
    enum SegueIdentifier: String {
        case UnwindToMain
        case ShowShareResult
    }
    
    var locationTrackType: LocationTrackType = .OneShot
    var locationTrackHandler: LocationTrackHandler!
    
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet var exchangeStatusLabel: UILabel!
    
    final var image: UIImage!
    private var receivedPhoto: Photo?
    private var mediumAdView: GADBannerView!

    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testImageView?.image = image
        initMediumAdView()
        initLocationHandler()
    }
    
    // MARK: - Init
    
    private func initMediumAdView() {
        mediumAdView = GADBannerView.preloadedMediumAdViewWithUnitId(AdUnitId, rootViewController: self)
        mediumAdView.hidden = true
        
        view.addSubview(mediumAdView)
        mediumAdView.snp_makeConstraints { make in
            make.bottom.equalTo(self.view)
            make.centerX.equalTo(self.view)
        }
    }
    
    private func initLocationHandler() {
        locationTrackHandler = LocationTrackHandler(delegate: self)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowShareResult:
            let navigationViewController = segue.destinationViewController as! UINavigationController
            let shareResultViewController = navigationViewController.topViewController as! ShareResultViewController
            shareResultViewController.photo = receivedPhoto
            
        case .UnwindToMain:
            // TODO: 돌아가기 전 필요한 처리가 있다면 해줄 것
            print("UnwindToMain")
        }
    }

    // MARK: - IBAction 
    
    @IBAction func shareButtonDidTap(sender: AnyObject) {
        // 현재 위치를 가져오는데 시간이 걸릴 경우 Alert 대용으로 간단한 HUD를 추가. 추구 필요하면 문구도 넣을 것. ex)"위치 가져오는 중..."
        SVProgressHUD.show()
        requestLocationUpdate()
    }
    
    final func locationDidUpdate(location: CLLocation) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            NSThread.sleepForTimeInterval(NSTimeInterval(1))
            dispatch_async(dispatch_get_main_queue()) {
                SVProgressHUD.dismiss()
            }
        }
        sharePhotoWithLocation(location)
    }
    
    private func sharePhotoWithLocation(location: CLLocation) {
        // TODO: 우선 대충만 구현, 추후 보강 필요
        upscaleViews { _ in
            self.downScaleAndTranslate { _ in
                self.moveNavigationBarAndShareButton { _ in
                    self.addExchangeStatusView()
                    self.showMediumAdView()
                    self.exchangePhotoWithLocation(location,
                        sendCompletion: {
                            // TODO: 로컬라이징 필요
                            self.exchangeStatusLabel.text = "Receiving..."
                        }, receiveCompletion: { photos in
                            if photos?.count > 0 {
                                self.receivedPhoto = photos?[0]
                                self.performSegueWithIdentifier(.ShowShareResult, sender: self)
                            } else {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Photo Exchange
    
    func exchangePhotoWithLocation(location: CLLocation, sendCompletion: PhotoExchanger.SendCompletion,
        receiveCompletion: PhotoExchanger.ReceiveCompletion) {
            let photo = Photo.create(message: textField.text!, departLocation: location)
            PhotoExchanger.exchange(photo, image: image, departLocation: location, sendCompletion: sendCompletion,
                receiveCompletion: receiveCompletion)
    }
    
    // MARK: - Animation
    
    func upscaleViews(completion: (Bool) -> Void) {
        UIView.animateWithDuration(0.2, delay: 0.3, options: UIViewAnimationOptions(),
            animations: {
                self.testImageView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.textField.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }, completion: completion)
    }
    
    func downScaleAndTranslate(completion: (Bool) -> Void) {
        UIView.animateWithDuration(0.3,
            animations: {
                self.testImageView.transform = CGAffineTransformMakeScale(0.01, 0.01)
                self.textField.transform = CGAffineTransformMakeScale(0.01, 0.01)
                self.testImageView.alpha = 0
                self.textField.alpha = 0
            }, completion: completion)
    }
    
    func moveNavigationBarAndShareButton(completion: (Bool) -> Void) {
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear,
            animations: {
                self.moveNavigationBar()
                self.moveShareButton()
        }, completion: completion)
    }
    
    func moveNavigationBar() {
        if let navigationBar = self.navigationController?.navigationBar {
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            navigationBar.frame.origin.y -= (navigationBar.frame.height + statusBarHeight)
        }
    }
    
    func moveShareButton() {
        // TODO: 애드몹 높이를 뺀 값에서 버튼이 적당히 중앙에 맞게 높이를 맞추어줄 것
        // constraints가 결국 안될 때를 대비해서 frame 조절하는 부분 주석 남김
        
//        var buttonFrame = self.shareButton.frame
//        buttonFrame.origin.y -= 400
//        self.shareButton.frame = buttonFrame
        
        self.testImageView.removeAllConstraints()
        self.textField.removeAllConstraints()
        
        self.shareButton.snp_updateConstraints { make in
            make.top.equalTo((self.topLayoutGuide as! UIView).snp_bottom).offset(50)
        }
        self.shareButton.layoutIfNeeded()
    }
    
    func addExchangeStatusView() {
        self.view.addSubview(self.exchangeStatusLabel)
        // 로컬라이징 필요
        self.exchangeStatusLabel.text = "Sending..."
        self.exchangeStatusLabel.snp_makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.shareButton.snp_bottom).offset(30)
        }
    }
    
    func showMediumAdView() {
        mediumAdView.hidden = false
    }
}
