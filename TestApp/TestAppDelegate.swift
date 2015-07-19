//
//  AppDelegate.swift
//  Camera
//
//  Created by Tony Xiao on 6/16/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import UIKit
import Core

@UIApplicationMain
class TestAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func showPlayer() {
        let videos = [PlayerVideoViewModel(
            url: NSURL(string: "https://v.cdn.vine.co/r/videos/5B77925E891217906329730072576_3e987288317.3.3.11608692995557014311.mp4")!,
            duration: 6,
            timestamp: NSDate(),
            avatarURL: NSURL(string: "https://s10tv.blob.core.windows.net/s10tv-dev/e9iNi8Xt6riZ2rDq4/profilepic/503F4409-0938-42F1-8691-772023E24915/CfRwWcJt7PEKg5hyN.jpg")!
        ), PlayerVideoViewModel(
            url: NSURL(string: "https://v.cdn.vine.co/r/videos/89F94EC3621216192216171937792_3476958eaf4.3.3.9427939328810040060.mp4")!,
            duration: 6,
            timestamp: NSDate(),
            avatarURL: NSURL(string: "https://s10tv.blob.core.windows.net/s10tv-dev/e9iNi8Xt6riZ2rDq4/profilepic/503F4409-0938-42F1-8691-772023E24915/CfRwWcJt7PEKg5hyN.jpg")!
        )]
        
        let sb = UIStoryboard(name: "AVKit", bundle: nil)
        let player = sb.instantiateViewControllerWithIdentifier("Player") as! PlayerViewController
        player.interactor = PlayerInteractor()
        player.interactor.videoQueue = videos
        
        let root = UINavigationController(rootViewController: player)
        window?.rootViewController = root
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        showPlayer() 
        return true
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


}

