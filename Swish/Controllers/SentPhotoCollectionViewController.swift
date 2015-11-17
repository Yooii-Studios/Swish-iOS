//
//  SentPhotoCollectionViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 11. 17..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

// TODO: 디바이스 / 2 - 마진 = 한 셀의 너비가 되게 계산하고, wrap_content 처럼 높이가 자동적으로 정해질 수 있게 구현 필요
class SentPhotoCollectionViewController: UIViewController {

    @IBOutlet weak var photoCollectionView: UICollectionView!

    private var sentPhotos: Array<Photo>!
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sentPhotos = SwishDatabase.sentPhotos()
        adjustCollectionViewCellSize()
    }
    
    private func adjustCollectionViewCellSize() {
        let deviceWidth = DeviceHelper.deviceWidth
        
        // TODO: 나중에 좀 더 디테일하게 width를 잡아줄 것. 좌, 중간, 우 간격 15씩 설정, 추후 이 숫자는 상수로 따로 뺄 것
        let itemWidth = (deviceWidth - 15 * 3) / 2
        
        (photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize =
            CGSize(width: itemWidth, height: itemWidth * 1.3)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: 디테일 컨트롤러 구현시 SegueHandlerType과 함께 추가 구현해줄 것
    }
    
    // MARK: - UICollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sentPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->
        UICollectionViewCell {
            let cell = dequeueReusableCell(collectionView, atIndexPath: indexPath)
            cell.clear()
            // TODO: 추후 아트 픽스된 이후 스토리보드에서 반투명 UIView opacity 조절 필요
            initCell(cell, atIndexPath: indexPath)
            return cell
    }
    
    private func dequeueReusableCell(collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) ->
        SentPhotoViewCell {
            return collectionView.dequeueReusableCellWithReuseIdentifier("SentPhotoViewCell", forIndexPath: indexPath)
                as! SentPhotoViewCell
    }
    
    private func initCell(cell: SentPhotoViewCell, atIndexPath indexPath: NSIndexPath) {
        let photo = sentPhotos[indexPath.row]
        PhotoImageHelper.imageWithPhoto(photo) { image in
            cell.imageView.image = image
            cell.messageLabel.text = photo.message
            self.initStatusImageView(cell.statusImageView, withPhotoState: photo.photoState)
        }
    }
    
    private func initStatusImageView(imageView: UIImageView, withPhotoState photoState: PhotoState) {
        let imgResourceName = photoState.sentStateImgResourceName
        imageView.image = UIImage(named: imgResourceName)
    }
    
    // MARK: - UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: ReceivedPhotoViewController 구현 후 SeugeHandlerType과 함께 추가 구현 필요
        //        self.performSegueWithIdentifier("", sender: self)
    }
}
