//
//  OverflowViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 16..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class OverflowViewController: UITableViewController {

    private let FacebookUrl = "https://www.facebook.com/YooiiMooii"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        self.navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
//        navigationController?.navigationBar.barStyle = .Black
        
        // TODO: 네비게이션바가 transelucent가 되지 않고 opaque가 되는 방법을 찾아봐야 함
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("overflowCell", forIndexPath: indexPath)

        let label = cell.viewWithTag(101) as! UILabel
        
        // 로컬라이징
        switch indexPath.row {
        case 0:
            label.text = "About Swish"
        case 1:
            label.text = "Settings"
        case 2:
            label.text = "Rate this app"
        case 3:
            label.text = "Like on Facebook"
        default:
            label.text = ""
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            break
        case 1:
            break
        case 2:
            // TODO: 출시 전 Rate 기능 구현할 것
            break
        case 3:
            if let url = NSURL(string: FacebookUrl) {
                UIApplication.sharedApplication().openURL(url)
            }
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
