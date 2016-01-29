//
//  PhotoTrendsViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 1. 29..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class PhotoTrendsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var photoTrends: PhotoTrends!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: 로컬러아징(Photo Trends 바 타이틀)
        
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        PhotoTrendsLoader.load { (photoTrends) -> Void in
            if let photoTrends = photoTrends {
                self.photoTrends = photoTrends
                self.tableView.reloadData()
                self.title = photoTrends.country.name
            }
        }
    }

    // MARK: - Table View
    
    final func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let photoTrends = self.photoTrends {
            return photoTrends.trendingPhotos.count
        } else {
            return 0
        }
    }
    
    final func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(tableView, atIndexPath: indexPath)
        cell.clear()
        cell.initWithPhotoTrend(self.photoTrends.trendingPhotos[indexPath.row])
        return cell
    }
    
    private func dequeueReusableCell(tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> PhotoTrendsViewCell {
        return tableView.dequeueReusableCellWithIdentifier("PhotoTrendsViewCell") as! PhotoTrendsViewCell
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - IBAction
    
    @IBAction func backButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
