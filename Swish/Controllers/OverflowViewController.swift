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

    // MARK: - Table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("overflowCell", forIndexPath: indexPath)

        let label = cell.viewWithTag(101) as! UILabel
        
        // TODO: 로컬라이징
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
            showAboutSwish()
            break
        case 1:
            showSettings()
            break
        case 2:
            // TODO: 출시 전 Rate 기능 구현할 것
            break
        case 3:
            openFacebookPage()
        default:
            break
        }
    }
    
    private func showAboutSwish() {
        let storyboard = UIStoryboard(name: "Overflow", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("AboutSwish")
        showViewController(viewController, sender: self)
    }
    
    private func showSettings() {
        let storyboard = UIStoryboard(name: "Overflow", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("Settings")
        showViewController(viewController, sender: self)
    }
    
    private func openFacebookPage() {
        UIApplication.sharedApplication().openURL(NSURL(string: FacebookUrl)!)
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
