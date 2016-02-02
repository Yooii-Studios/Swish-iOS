//
//  ChatViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 1..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.title = photo.sender.name
        
        initTableView()
    }
    
    private func initTableView() {
        tableView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
    }
    
    final func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Table view data source

    final func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    final func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
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
    
    @IBAction func backButtonDidTap() {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
