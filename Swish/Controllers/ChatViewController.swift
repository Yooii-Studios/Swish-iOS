//
//  ChatViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 1..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatMessageSender {

    struct Metric {
        static let ChatMessageFetchAmount: Int = 15
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableViewTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraints: NSLayoutConstraint!
    
    var photo: Photo!
    var photoId: Photo.ID {
        return photo.id
    }
    var isKeyboardAnimating: Bool = false
    var isLoadingChatItems: Bool = true
    var chatMessages: Array<ChatMessage>!
    
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
        initTableViewDelegates()
        initTableViewTapGesture()
        initChatMessages()
    }
    
    private func initChatMessages() {
        chatMessages = SwishDatabase.loadChatMessages(photoId, startIndex: 0, amount: Metric.ChatMessageFetchAmount)
        
        tableView.reloadData() {
            self.isLoadingChatItems = false
            self.scrollToBottom()
            SwishDatabase.updateAllChatRead(self.photoId)
        }
    }
    
    private func initPhotoObserver() {
        PhotoObserver.observeChatMessagesForPhoto(photo, owner: self) { [weak self] index in
            if let photoId = self?.photo.id {
                SwishDatabase.updateAllChatRead(photoId)
                self?.chatMessages.insert((self?.photo.chatMessages[index])!, atIndex: 0)
                if let chatItemsCount = self?.chatMessages.count {
                    self?.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: chatItemsCount - 1, inSection: 0)],
                        withRowAnimation: .None)
                    self?.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: chatItemsCount - 1, inSection: 0),
                        atScrollPosition: .Bottom, animated: false)
                }
            }
        }
    }
    
    private func initTableViewDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
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
        guard !chatMessages.isEmpty else { return }
        
        let lastIndexPath = NSIndexPath(forRow: chatMessages.count - 1, inSection: 0)
        tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .None, animated: false)
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
            tableViewBottomConstraints.constant = tableViewBottomConstraints.constant + keyboardFrame.size.height
            
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
            let chatMessageCount = chatMessages.count
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
        if let chatMessages = chatMessages {
            return chatMessages.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO: 추후 DateDivider UI 추가 필요
        // TODO: 추후 각 셀 초기화 로직 리팩토링할 것
        let chatMessage = chatMessages[chatMessages.count - 1 - indexPath.row]
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && !isLoadingChatItems {
            if photo.chatMessages.count != chatMessages.count {
                loadMoreChatItems()
            }
        } else {
            isLoadingChatItems = false
        }
    }
    
    private func loadMoreChatItems() {
        guard !isLoadingChatItems else { return }
        isLoadingChatItems = true
        
        // TODO: var로 변경하고 날짜 구분 아이템 추가
        let olderChatItems = SwishDatabase.loadChatMessages(photoId, startIndex: chatMessages.count,
            amount: Metric.ChatMessageFetchAmount)
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.chatMessages = self.chatMessages + olderChatItems
            
            // TODO: 날짜 구분 아이템 추가
            // TODO: 전부 읽어와서 읽어올 예상 갯수보다 적으면 마지막 로딩, 날짜 구분선 넣어주기
            // TODO: 안드로이드 로직 참고해서 여러 예외 상황 처리하고 날짜 구분선 넣을 것
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData() {
                    let olderChatItemsHeight = (0..<olderChatItems.count)
                        .map { NSIndexPath(forRow: $0, inSection: 0) }
                        .map { self.tableView(self.tableView, heightForRowAtIndexPath: $0) }
                        .reduce(0, combine: +)
                    
                    self.tableView.contentOffset.y = olderChatItemsHeight
                    self.isLoadingChatItems = false
                }
            })
        }
    }
    
    // TODO: 추후 UI가 들어갔을 때 이 부분을 순수히 계산으로 처리할 지, self-sizing으로 처리할 지 고민해야함
    // 1줄 이상의 텍스트가 포함된 셀일 때 더욱 문제가 됨
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
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
