//
//  SwishInfoViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 16..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class SwishInfoViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: 로컬라이징
        title = "Swish Info"
    }

    // MARK: - Table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.row == 0 || indexPath.row == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("swishInfoCell", forIndexPath: indexPath)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("versionCell", forIndexPath: indexPath)
            setUpVersionCell(cell)
        }
        
        let label = cell.viewWithTag(101) as! UILabel
        
        // TODO: 로컬라이징
        switch indexPath.row {
        case 0:
            label.text = "Yooii Studios"
        case 1:
            label.text = "License"
        case 2:
            label.text = "Version"
        default:
            label.text = ""
        }

        return cell
    }
    
    private func setUpVersionCell(cell: UITableViewCell) {
        let versionLabel = cell.viewWithTag(102) as! UILabel
        versionLabel.text = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            openYooiiHomepage()
            break
        default:
            break
        }
    }
    
    private func openYooiiHomepage() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://yooiistudios.com")!)
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
