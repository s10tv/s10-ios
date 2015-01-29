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
        
        NSValueTransformer.setValueTransformer(PhotosValueTransformer(), forName: "PhotosValueTransformer")
        
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
        let user = User.MR_createEntity()
        user.firstName = "Tony";

        var photos : [Photo] = Array<Photo>()
        for index in 1...6 {
            let url = "https://s10.blob.core.windows.net/default/girl-00\(index).jpg"
            photos.append(Photo(url: url))
        }
        user.photos = photos
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActive()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
}
