//
//  AppDelegate.swift
//  Swish
//
//  Created by Wooseong Kim on 2015. 9. 8..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit
import CoreData
import DeviceUtil
import IQKeyboardManager

typealias NotificationInfo = [NSObject: AnyObject]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, var didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        SwishDatabase.migrate()
        initIQKeyboardManager()
        
        if let notificationInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NotificationInfo {
            print("Launched from push notification")
            handleRemoteNotification(notificationInfo, updateUI: false)
        }
        
        return true
    }
    
    private func initIQKeyboardManager() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor = true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - APNS
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        MeManager.updateMyDeviceToken(deviceToken.description)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // TODO: Simulator의 경우를 제외하고는 이 쪽으로 Flow가 넘어오는 것을 본 적은 없지만, 만에 하나 있을 예외 처리를 위해 언젠가는 구현해야할듯
        print("Fail to get token : \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        handleRemoteNotification(userInfo, updateUI: true)
        print("Receive notification")
    }
    
    func handleRemoteNotification(notificationInfo: NotificationInfo, updateUI: Bool) {
        // TODO: Like, Dislike, Chat 관련 알람을 처리해줘야함
        // TODO: Badge 관련 처리를 해줘야함
        print("Handle notification here: \(notificationInfo)")
    }
}

