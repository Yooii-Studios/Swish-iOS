//
//  PhotoPickerViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import Photos

class PhotoPickerViewController: UICollectionViewController {
    
    let itemCountInARow = 3
    let selectedAssets : [PHAsset] = []
    var photoMediaFetchResult : PHFetchResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
    }
    
    func initUI() {
        initCollectionView()
    }
    
    func initData() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        switch (authStatus) {
            case PHAuthorizationStatus.NotDetermined:
                requestAuthorizaitionStatus()
            case PHAuthorizationStatus.Restricted, PHAuthorizationStatus.Denied :
                showAccessDenied()
            default:
                fetchAssets()
        }
    }
    
    func initCollectionView() {
        let collectionViewFlowlayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewFlowlayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionViewFlowlayout.minimumInteritemSpacing = 5
        collectionViewFlowlayout.minimumLineSpacing = 5
        
        collectionView!.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView!.backgroundColor = UIColor.whiteColor()
    }
    
    func requestAuthorizaitionStatus() {
        PHPhotoLibrary.requestAuthorization { (authStatus) -> Void in
            switch (authStatus) {
            case PHAuthorizationStatus.Authorized:
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.fetchAssets()
                })
            default:
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showAccessDenied()
                })
            }
        }
    }
    
    func showAccessDenied() {
        // TODO : 일단은 Picker 내리는 것으로 처리, 후에 Denied에 대한 안내 문구 띄워줘야 할 듯
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchAssets() {
        self.photoMediaFetchResult = MediaLoader.fetchPhotoAssets()
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelBarButtonDidTap() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Delegate
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoMediaFetchResult != nil ? (photoMediaFetchResult?.count)! : 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath)
            as! PhotoCollectionViewCell
        let asset = photoMediaFetchResult?.objectAtIndex(indexPath.row) as! PHAsset
        MediaLoader.setAssetImageToImageView(asset, targetSize: cell.bounds.size, imageView: cell.imageView)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellSize = calculateCollectionViewCellSize()
        return CGSizeMake(cellSize, cellSize);
    }
    
    func calculateCollectionViewCellSize() -> CGFloat {
        let collectionViewFlowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let collectionViewHorizontalInset = collectionViewFlowLayout.sectionInset.left
            + collectionViewFlowLayout.sectionInset.right
        let totalInterItemSpacing = CGFloat(itemCountInARow - 1) * collectionViewFlowLayout.minimumInteritemSpacing
        let cellSize = (collectionView!.bounds.width - totalInterItemSpacing - collectionViewHorizontalInset)
            / CGFloat(itemCountInARow)
        
        return cellSize
    }
}
