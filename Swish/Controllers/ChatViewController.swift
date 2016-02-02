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
    
    var photo: Photo!
    var photoId: Photo.ID {
        return photo.id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        title = photo.sender.name
        initTableView()
        initPhotoObserver()
    }
    
    private func initTableView() {
        tableView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
    }
    
    private func initPhotoObserver() {
        PhotoObserver.observeChatMessagesForPhoto(photo, owner: self) { [weak self] index in
            // 추후 해당 인덱스만 추가될 수 있게 로직 개선 필요
            self?.tableView.reloadData()
        }
    }
    
    final func hideKeyboard() {
        view.endEditing(true)
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
        
    }
    
    @IBAction func sendbuttonDidTap() {
        if let message = textField.text {
            let chatMessage = ChatMessage.create(message, senderId: MeManager.me().id)

            // TODO: 나중에 APNS와 연결한 뒤 ChatMessageSender comfort해서 연결해줄 것. 그전에는 로컬 DB에만 저장해서 테스트
            chatMessage.state = .Success
            SwishDatabase.saveChatMessage(photo.id, chatMessage: chatMessage)
        }
        
        textField.text = ""
    }
}
