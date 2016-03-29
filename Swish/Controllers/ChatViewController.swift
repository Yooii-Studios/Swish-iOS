//
//  ChatViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2016. 2. 1..
//  Copyright © 2016년 Yooii Studios Co., LTD. All rights reserved.
//

import UIKit
import DateTools

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatMessageSender {

    struct Metric {
        static let ChatMessageFetchAmount: Int = 20
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
    var isAllChatMessagesLoaded: Bool = false
    var chatItems: Array<ChatItem>!
    
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
        chatItems = SwishDatabase.loadChatMessages(photoId, startIndex: 0, amount: Metric.ChatMessageFetchAmount)
        
        // TODO: 최초 DateDivider 추가해주기
        
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
                
                var isDateDifferent: Bool = false
                let chatMessagesCount = self?.photo.chatMessages.count
                if chatMessagesCount > 1 {
                    let previousLatestChatMessage = self?.photo.chatMessages[1]
                    if previousLatestChatMessage?.receivedDate.day() != NSDate().day() {
                        isDateDifferent = true
                    }
                } else if chatMessagesCount == 1 {
                    isDateDifferent = true
                }
                
                if isDateDifferent {
                    let chatDateDivider = ChatDateDivider(eventTime: NSDate())
                    self?.chatItems.insert(chatDateDivider, atIndex: 0)
                }
                self?.chatItems.insert((self?.photo.chatMessages[index])!, atIndex: 0)
                
                if let chatItemsCount = self?.chatItems.count {
                    var indexPaths = [NSIndexPath(forRow: chatItemsCount - 1, inSection: 0)]
                    if isDateDifferent {
                        indexPaths.insert(NSIndexPath(forRow: chatItemsCount - 2, inSection: 0), atIndex: 0)
                    }
                    
                    self?.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
    }
    
    final func hideKeyboard() {
        if !isKeyboardAnimating {
            view.endEditing(true)
        }
    }
    
    private func scrollToBottom() {
        guard !chatItems.isEmpty else { return }
        
        let lastIndexPath = NSIndexPath(forRow: chatItems.count - 1, inSection: 0)
        tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .None, animated: false)
    }
    
    private func initKeyboardObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
            name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow(_:)),
            name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
            name:UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard callbacks
    
    final func keyboardWillShow(notification: NSNotification) {
        isKeyboardAnimating = true
        
        let info = notification.userInfo!
        let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size.height
        var contentInsets: UIEdgeInsets
        
        if isLastChatMessageVisible() {
            contentInsets = UIEdgeInsetsMake(keyboardHeight, 0, 0, 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
            
            animateTableViewWithKeyboardHeight(keyboardHeight, withInfo: info)
        } else {
            contentInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    final func animateTableViewWithKeyboardHeight(keyboardHeight: CGFloat, withInfo info: [NSObject : AnyObject]) {
        let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue
        
        tableViewTopConstraints.constant = -keyboardHeight
        tableViewBottomConstraints.constant = tableViewBottomConstraints.constant + keyboardHeight
        
        let options = UIViewAnimationOptions(rawValue: animationCurve)
        UIView.animateWithDuration(animationDuration, delay: 0, options: options, animations: { _ in
            self.view.layoutIfNeeded()
            }, completion: nil)
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
            let chatMessageCount = chatItems.count
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
        return chatItems?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO: 추후 DateDivider UI 추가 필요
        // TODO: 추후 각 셀 초기화 로직 리팩토링할 것
        let chatItem = chatItems[chatItems.count - 1 - indexPath.row]
        
        if let chatMessage = chatItem as? ChatMessage {
            if chatMessage.isMyMessage {
                let cell = tableView.dequeueReusableCellWithIdentifier("MyChatViewCell", forIndexPath: indexPath) as!
                MyChatViewCell
                cell.messageLabel.text = chatMessage.message
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("OtherUserChatViewCell", forIndexPath: indexPath)
                    as! OtherUserChatViewCell
                cell.messageLabel.text = chatMessage.message
                
                return cell
            }
        } else {
            let chatDateDivider = chatItem as! ChatDateDivider
            let cell = tableView.dequeueReusableCellWithIdentifier("DateDividerViewCell", forIndexPath: indexPath) as!
            DateDividerViewCell
            cell.dateLabel.text = chatDateDivider.dateInfo
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && !isLoadingChatItems {
            loadMoreChatItems()
        } else {
            isLoadingChatItems = false
        }
    }
    
    private func loadMoreChatItems() {
        guard !isAllChatMessagesLoaded else { return }
        isLoadingChatItems = true
        
        let olderChatMessages = SwishDatabase.loadChatMessages(photoId, startIndex: chatItems.count,
            amount: Metric.ChatMessageFetchAmount)
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let olderChatItems: Array<ChatItem> = olderChatMessages
            
            // TODO: 날짜 구분 아이템 추가
            
            if olderChatItems.count < Metric.ChatMessageFetchAmount {
                self.isAllChatMessagesLoaded = true
                // TODO: 전부 읽어와서 읽어올 예상 갯수보다 적으면 마지막 로딩, 날짜 구분선 넣어주기
                // TODO: 제일 첫 ChatItem 조사해서 날짜 구분선 또 넣어주기
                // TODO: 안드로이드 로직 참고해서 여러 예외 상황 처리하고 날짜 구분선 넣을 것
            }
            self.chatItems = self.chatItems + olderChatItems
        
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData() {
                    let olderChatItemsHeight = (0..<olderChatItems.count)
                        .map { NSIndexPath(forRow: $0, inSection: 0) }
                        .map { self.tableView(self.tableView, heightForRowAtIndexPath: $0) }
                        .reduce(0, combine: +)
                    
                    // TODO: 날짜구분선 높이도 더해줄 것
                    
                    self.tableView.contentOffset.y = olderChatItemsHeight
                    self.isLoadingChatItems = false
                }
            })
        }
    }
    
    // TODO: 추후 UI가 들어갔을 때 이 부분을 순수히 계산으로 처리할 지, self-sizing으로 처리할 지 고민해야함
    // 1줄 이상의 텍스트가 포함된 셀일 때 더욱 문제가 됨
    // 또한 날짜 구분 셀의 높이도 따로 더해줘야 함
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
        let storyboard = UIStoryboard(name: "PhotoDetail", bundle: nil)
        let photoDetailViewController = storyboard.instantiateInitialViewController() as! PhotoDetailViewController
        photoDetailViewController.photoId = photoId
        presentViewController(photoDetailViewController, animated: true, completion: nil)
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
