//
//  ReceivedPhotosViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 3..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

// TODO: 디바이스 / 2 - 마진 = 한 셀의 너비가 되게 계산하고, wrap_content 처럼 높이가 자동적으로 정해질 수 있게 구현 필요
class ReceivedPhotoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    private var receivedPhotos: Array<Photo>!
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        receivedPhotos = SwishDatabase.receivedPhotos()
        adjustCollectionViewCellSize()
    }
    
    private func adjustCollectionViewCellSize() {
        let deviceWidth = DeviceHelper.deviceWidth
        
        // TODO: 나중에 좀 더 디테일하게 width를 잡아줄 것. 좌, 중간, 우 간격 15씩 설정, 추후 이 숫자는 상수로 따로 뺄 것
        let itemWidth = (deviceWidth - 15 * 3) / 2

        (photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize =
            CGSize(width: itemWidth, height: itemWidth * 1.4)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: ReceivedPhotoViewController 구현 후 SeugeHandlerType과 함께 추가 구현 필요
        /*
        if segue.identifier == "" {
            let indexPaths = collectionView.indexPathsForSelectedItems()
            let indexPath = indexPaths![0]
            
            let viewController = segue.destinationViewController as! ReceivedPhotoViewController
        }
        */
    }
    
    // MARK: - IBAction
    
    // Debug용: 코드 중복이 있어도 아래 메서드는 추후 삭제될 것이기에 문제되지 않을 듯
    @IBAction func photoMapButtonDidTap(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "PhotoMap", bundle: nil)
        let navigationViewController =
        storyboard.instantiateViewControllerWithIdentifier("PhotoMapNavController") as! UINavigationController
        
        // TODO: 나중에 "보낸 사진 디테일 / 받은 사진 디테일"로 옮겨진 후 해당하는 사진 ID 넣을 것
        // TODO: 보낸 사진의 경우 도착한 사진만 이 화면으로 들어갈 수 있게 구현해야 함
        let photoCollectionMapViewController = navigationViewController.topViewController
            as! PhotoMapViewController
        photoCollectionMapViewController.photoId = 909
        
        showViewController(navigationViewController, sender: self)
    }
    
    @IBAction func photoCollectionMapButtonDidTap(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "PhotoMap", bundle: nil)
        let navigationViewController =
        storyboard.instantiateViewControllerWithIdentifier("PhotoCollectionMapNavController") as! UINavigationController
        
        let photoCollectionMapViewController = navigationViewController.topViewController
            as! PhotoCollectionMapViewController
        photoCollectionMapViewController.photoType = .Received

        showViewController(navigationViewController, sender: self)
    }
    
    // MARK: - UICollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return receivedPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->
        UICollectionViewCell {
            let cell = dequeueReusableCell(collectionView, atIndexPath: indexPath)
            cell.clear()
            cell.initWithPhoto(receivedPhotos[indexPath.row])
            return cell
    }
    
    private func dequeueReusableCell(collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) ->
        ReceivedPhotoViewCell {
            return collectionView.dequeueReusableCellWithReuseIdentifier("ReceivedPhotoViewCell", forIndexPath: indexPath)
                as! ReceivedPhotoViewCell
    }
    
    // MARK: - UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: ReceivedPhotoViewController 구현 후 SeugeHandlerType과 함께 추가 구현 필요
//        self.performSegueWithIdentifier("", sender: self)
    }
}
