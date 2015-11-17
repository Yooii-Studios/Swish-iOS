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
    
    // MARK: - UICollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return receivedPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->
        UICollectionViewCell {
            let cell = dequeueReusableCell(collectionView, atIndexPath: indexPath)
            cell.clear()
            initCell(cell, atIndexPath: indexPath)
            return cell
    }
    
    private func dequeueReusableCell(collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) ->
        ReceivedPhotoViewCell {
            return collectionView.dequeueReusableCellWithReuseIdentifier("receivedPhotoCell", forIndexPath: indexPath)
                as! ReceivedPhotoViewCell
    }
    
    private func initCell(cell: ReceivedPhotoViewCell, atIndexPath indexPath: NSIndexPath) {
        let photo = receivedPhotos[indexPath.row]
        PhotoImageHelper.imageWithPhoto(photo) { image in
            cell.imageView.image = image
            cell.userNameLabel.text = photo.sender.name
            cell.messageLabel.text = photo.message
            // TODO: 거리 관련 유틸리티 추후 구현해서 적용할 것
            cell.distanceLabel.text = "6230 km"
        }
    }
    
    // MARK: - UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: ReceivedPhotoViewController 구현 후 SeugeHandlerType과 함께 추가 구현 필요
//        self.performSegueWithIdentifier("", sender: self)
    }
}
