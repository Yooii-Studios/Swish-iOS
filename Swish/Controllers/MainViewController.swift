//
//  ViewController.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let photoPicker = UIImagePickerController()
    @IBOutlet var testImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cameraButtonDidTap(sender: UIButton!) {
        NSLog("cameraButtonDidTap")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            imagePickerController.allowsEditing = false
            showViewController(imagePickerController, sender: self)
        } else {
            NSLog("cameraNotAvailable")
        }
    }
    
    @IBAction func testButtonDidTap(sender: AnyObject) {
        photoPicker.delegate = self
        photoPicker.sourceType = .PhotoLibrary
        photoPicker.allowsEditing = false
        showViewController(photoPicker, sender: self)
    }
    
    @IBAction func testLoadButtonDidTap(sender: AnyObject) {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("qwerasdf")
        testImageView.image = UIImage(contentsOfFile: fileURL.path!)
    }
    
    @IBAction func testActionButtonDidTap(sender: AnyObject) {
        UserServer.registerMe(
            onSuccess: { (me: Me) -> () in
                SwishDatabase.saveMe(me)
                
                PhotoServer.blockChat(662,
                    onSuccess: { (result) -> () in
                        print("blockChat: onSuccess")
                    }, onFail: { (error) -> () in
                        print("blockChat: onFail")
                })
                
//                PhotoServer.photoResponsesWith(SwishDatabase.me().id,
//                    departLocation: CLLocation(latitude: 127.0001, longitude: 35.0001), photoCount: 1, onSuccess: { (photos) -> () in
//                        print(photos)
//                        let photoResponse = photos[0]
//                        UserServer.otherUserWith(photoResponse.userId,
//                            onSuccess: { (otherUser) -> () in
//                                SwishDatabase.saveOtherUser(otherUser)
//                                SwishDatabase.saveReceivedPhoto(otherUser,
//                                    photo: photoResponse.photo)
//                                
//                                PhotoServer.updatePhotoState(photoResponse.photo.id, state: .Liked,
//                                    onSuccess: { (result) -> () in
//                                        let msg = ChatMessage.create("test msg from iOS...", senderId: me.id, builder: { (chatMessage: ChatMessage) -> () in })
//                                        SwishDatabase.saveChatMessage(photoResponse.photo, chatMessage: msg)
//                                        PhotoServer.sendChatMessage(msg, onSuccess: { (result) -> () in
//                                            print("sendChatMessage: onSuccess")
//                                            }, onFail: { (error) -> () in
//                                                print("sendChatMessage: onFail")
//                                                print(error)
//                                        })
//                                    },
//                                    onFail: { (error) -> () in
//                                        print("updatePhotoState: onFail")
//                                        print(error)
//                                })
//                                
//                            }, onFail: { (error) -> () in
//                                
//                        })
//                    }, onFail: { (error) -> () in
//                        print(error)
//                })
                
                
                let photo = Photo.create()
                photo.message = "test message from ios photo"
                photo.departLocation = CLLocation(latitude: 127.0001, longitude: 35.0001)
                
                let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let fileURL = documentsURL.URLByAppendingPathComponent("qwerasdf")
                photo.localPath = fileURL.path!
//
//                PhotoServer.save(photo, userId: me.id,
//                    onSuccess: { (id: Photo.ID) -> () in
//                        photo.id = id
//                        SwishDatabase.saveSentPhoto(photo)
//                    }, onFail: { (error) -> () in
//                        
//                })
                
                
//                PhotoServer.photoStatesWith("3",
//                    onSuccess: { (photoStates) -> () in
//                        print(photoStates)
//                    }, onFail: { (error) -> () in
//                        print(error)
//                })
            }, onFail: { (error) -> () in
                print(error)
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Delegate Function
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if picker == photoPicker {
            NSLog("photoLibraryDidFinishPickingImage")
            picker.dismissViewControllerAnimated(false, completion: nil)
            
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileURL = documentsURL.URLByAppendingPathComponent("qwerasdf")
            UIImageJPEGRepresentation(image, 1.0)!.writeToFile(fileURL.path!, atomically: true)
        } else {
            NSLog("cameraDidFinishPickingImage")
            let storyboard = UIStoryboard(name: "Dressing", bundle: nil)
            let navigationViewController =
            storyboard.instantiateViewControllerWithIdentifier("dressingNaviViewController") as! UINavigationController
            let dressingViewController = navigationViewController.topViewController as! DressingViewController
            dressingViewController.testImage = image
            
            picker.dismissViewControllerAnimated(false, completion: nil)
            presentViewController(navigationViewController, animated: true, completion: nil)
        }
    }
}
