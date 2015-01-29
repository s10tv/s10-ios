//
//  AppDelegate.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/24/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import CoreData
import FacebookSDK
import MagicalRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var rootVC: RootViewController! {
        get {
            return window?.rootViewController as RootViewController
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
        let user = User.MR_createEntity()
        user.firstName = "Tony";
        println(user.firstName)
        println(user.objectID)
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        for index in 1...6 {
            let url = NSURL(string: "https://s10.blob.core.windows.net/default/girl-00\(index).jpg")
            println(url)
        }
        
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActive()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
}
