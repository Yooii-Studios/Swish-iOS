//
//  ChatViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 1..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, ChatMessageSender {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableViewTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraints: NSLayoutConstraint!
    
    var photo: Photo!
    var photoId: Photo.ID {
        return photo.id
    }
    var isKeyboardAnimating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTitle()
        initTableView()
        initPhotoObserver()
        initKeyboardObserver()
    }
    
    private func initTitle() {
        title = photo.sender.name
    }
    
    private func initTableView() {
        initDataSource()
        initTableViewTapGesture()
        scrollToBottom()
    }
    
    private func initPhotoObserver() {
        PhotoObserver.observeChatMessagesForPhoto(photo, owner: self) { [weak self] index in
            if let photoId = self?.photo.id {
                SwishDatabase.updateAllChatRead(photoId)
            }
            // 추후 해당 인덱스만 추가될 수 있게 로직 개선 필요
            self?.tableView.reloadData()
            self?.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition:
                UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    private func initDataSource() {
        tableView.dataSource = self
    }
    
    private func initTableViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
    }
    
    final func hideKeyboard() {
        if !isKeyboardAnimating {
            view.endEditing(true)
        }
    }
    
    private func scrollToBottom() {
        tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.max), animated: false)
    }
    
    private func initKeyboardObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"),
            name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"),
            name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"),
            name:UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard callbacks
    
    final func keyboardWillShow(notification: NSNotification) {
        isKeyboardAnimating = true
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if isLastChatMessageVisible() {
            let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let animationCurve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue
            
            tableViewTopConstraints.constant = -keyboardFrame.size.height
            tableViewBottomConstraints.constant = self.tableViewBottomConstraints.constant + keyboardFrame.size.height
            
            let options = UIViewAnimationOptions(rawValue: animationCurve)
            UIView.animateWithDuration(animationDuration, delay: 0, options: options, animations: { _ in
                self.view.layoutIfNeeded()
                }, completion: nil)
        } else {
            var contentInsets: UIEdgeInsets
            if (UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)) {
                contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height, 0.0)
            } else {
                contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.width, 0.0)
            }
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    final func keyboardDidShow(notification: NSNotification) {
        isKeyboardAnimating = false
    }
    
    final func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue
        
        tableViewTopConstraints.constant = 0
        tableViewBottomConstraints.constant = (textField.superview?.frame.height)!
        tableView.contentInset = UIEdgeInsetsZero
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        
        let options = UIViewAnimationOptions(rawValue: animationCurve)
        UIView.animateWithDuration(animationDuration, delay: 0, options: options, animations: { _ in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func isLastChatMessageVisible() -> Bool {
        if let paths = tableView.indexPathsForVisibleRows {
            let chatMessageCount = photo.chatMessages.count
            for indexPath in paths {
                if indexPath.row == chatMessageCount - 1 || indexPath.row == chatMessageCount - 2 {
                    return true
                }
            }
        }
        return false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Table view data source

    final func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    final func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photo.chatMessages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO: 추후 DateDivider UI 추가 필요
        // TODO: 추후 각 셀 초기화 로직 리팩토링할 것
        let chatMessage = photo.chatMessages[indexPath.row]
        if chatMessage.isMyMessage {
            let cell = tableView.dequeueReusableCellWithIdentifier("MyChatViewCell", forIndexPath: indexPath) as!
            MyChatViewCell
            
            cell.messageLabel.text = chatMessage.message
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("OtherUserChatViewCell", forIndexPath: indexPath) as!
            OtherUserChatViewCell
            
            cell.messageLabel.text = chatMessage.message
            
            return cell
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
    
    // MARK: - IBAction
    
    @IBAction func backButtonDidTap() {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func imageButtonDidTap() {
        
    }
    
    @IBAction func blockButtonDidTap() {
        // TODO: 디버그용으로 추후 삭제 필요 
        let chatMessage = ChatMessage.create("Test!", senderId: photo.sender.id)
        chatMessage.state = .Success
        SwishDatabase.saveChatMessage(photo.id, chatMessage: chatMessage)
    }
    
    @IBAction func sendbuttonDidTap() {
        if let message = textField.text where message.characters.count > 0 {
            let chatMessage = ChatMessage.create(message, senderId: MeManager.me().id)
            sendChatMessage(chatMessage)
        }
        
        textField.text = ""
    }
}
