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
        initPhotos()
        initLongPressGestureRecognizer()
        adjustCollectionViewCellSize()
        refreshPhotoStates()
    }
    
    private func refreshPhotoStates() {
        SentPhotoStateLoader.instance.execute()
    }
    
    private func initPhotos() {
        sentPhotos = SwishDatabase.sentPhotos()
        
        PhotoObserver.observePhotoStateForPhotos(sentPhotos, owner: self) { [weak self] photoId, _ in
            for (index, photo) in (self?.sentPhotos)!.enumerate() {
                if photo.id == photoId {
                    self?.photoCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
                }
            }
        }
        
        PhotoObserver.observeRecentEventTimeForPhotos(sentPhotos, owner: self) { [weak self] photoId, eventTime in
            for (index, photo) in (self?.sentPhotos)!.enumerate() {
                if photo.id == photoId {
                    if let targetPhoto = self?.sentPhotos.removeAtIndex(index) {
                        self?.sentPhotos.insert(targetPhoto, atIndex: 0)
                        
                        let previousIndexPath = NSIndexPath(forRow:index, inSection: 0)
                        let targetIndexPath = NSIndexPath(forRow:0, inSection: 0)
                        self?.photoCollectionView.moveItemAtIndexPath(previousIndexPath, toIndexPath: targetIndexPath)
                    }
                }
            }
        }
    }
    
    private func initLongPressGestureRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized(_:)))
        photoCollectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func adjustCollectionViewCellSize() {
        let deviceWidth = DeviceHelper.deviceWidth
        
        // TODO: 나중에 좀 더 디테일하게 width를 잡아줄 것. 좌, 중간, 우 간격 15씩 설정, 추후 이 숫자는 상수로 따로 뺄 것
        let itemWidth = (deviceWidth - 15 * 3) / 2
        
        (photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize =
            CGSize(width: itemWidth, height: itemWidth * 1.3)
    }
    
    deinit {
        SentPhotoStateLoader.instance.cancel()
    }
    
    // MARK: - Navigation 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let cell = sender as? UICollectionViewCell, let indexPath = photoCollectionView.indexPathForCell(cell) else {
            return
        }
        let navigationViewController = segue.destinationViewController as! UINavigationController
        let detailViewController = navigationViewController.topViewController as! SentPhotoDetailViewController
        detailViewController.photo = sentPhotos[indexPath.row]
    }
    
    // MARK: - IBAction
    
    @IBAction func photoCollectionMapButtonDidTap(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "PhotoMap", bundle: nil)
        let navigationViewController =
        storyboard.instantiateViewControllerWithIdentifier("PhotoCollectionMapNavController") as! UINavigationController
        
        // TODO: 필요한 초기화 진행할 것
        let photoCollectionMapViewController = navigationViewController.topViewController
            as! PhotoCollectionMapViewController
        photoCollectionMapViewController.photoType = .Sent
        
        showViewController(navigationViewController, sender: self)
    }
    
    // MARK: - UICollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sentPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->
        UICollectionViewCell {
            let cell = dequeueReusableCell(collectionView, atIndexPath: indexPath)
            cell.clear()
            cell.initWithPhoto(sentPhotos[indexPath.row])
            // TODO: 추후 아트 픽스된 이후 스토리보드에서 반투명 UIView opacity 조절 필요
            return cell
    }
    
    private func dequeueReusableCell(collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) ->
        SentPhotoViewCell {
            return collectionView.dequeueReusableCellWithReuseIdentifier("SentPhotoViewCell", forIndexPath: indexPath)
                as! SentPhotoViewCell
    }
        
    // MARK: - UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: ReceivedPhotoViewController 구현 후 SeugeHandlerType과 함께 추가 구현 필요
        //        self.performSegueWithIdentifier("", sender: self)
    }
    
    // MARK: - Long Press
    
    func longPressRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPressRecognizer = gestureRecognizer as! UILongPressGestureRecognizer
        let locationInView = longPressRecognizer.locationInView(photoCollectionView)
        let state = longPressRecognizer.state
        
        if let indexPath = photoCollectionView.indexPathForItemAtPoint(locationInView) where state == .Began {
            showDeleteActinSheetWithIndexPath(indexPath)
        }
    }
    
    private func showDeleteActinSheetWithIndexPath(indexPath: NSIndexPath) {
        // TODO: 로컬라이징
        let alertController = UIAlertController(title: nil, message: "Do you really want to delete this photo?",
            preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
            SwishDatabase.deletePhoto(self.sentPhotos[indexPath.row].id)
            self.sentPhotos.removeAtIndex(indexPath.row)
            self.photoCollectionView.deleteItemsAtIndexPaths([indexPath])
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
