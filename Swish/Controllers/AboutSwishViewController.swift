//
//  AboutSwishViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 16..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class AboutSwishViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 로컬라이징
        title = "About Swish"
    }
    
    // MARK: - Table view 

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("aboutSwishCell", forIndexPath: indexPath)

        let label = cell.viewWithTag(101) as! UILabel
        
        // TODO: 로컬라이징
        switch indexPath.row {
        case 0:
            label.text = "Swish Info"
        case 1:
            label.text = "Recommend to your friends"
        case 2:
            label.text = "Credits"
        default:
            label.text = ""
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            showSwishInfo()
            break
        case 1:
            // TODO: 친구에게 추천하기 기능 구현하기
            break
        case 2:
            showCredit()
            break
        default:
            break
        }
    }
    
    private func showSwishInfo() {
        let storyboard = UIStoryboard(name: "Overflow", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("SwishInfo")
        showViewController(viewController, sender: self)
    }
    
    private func showCredit() {
        
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
