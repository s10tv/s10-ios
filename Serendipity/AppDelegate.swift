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
import ObjectiveDDP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var meteor: MeteorClient!
    var rootVC: RootViewController! {
        get {
            return window?.rootViewController as RootViewController
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSValueTransformer.setValueTransformer(PhotosValueTransformer(), forName: "PhotosValueTransformer")
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
        debugCreateTestUser()
        
        meteor = MeteorClient(DDPVersion: "1")
        meteor.ddp = ObjectiveDDP(URLString: "ws://s10.herokuapp.com/websocket", delegate: meteor)
        meteor.ddp.connectWebSocket()

        // Need better way to register observer that unregisters itself
        NSNotificationCenter.defaultCenter().addObserverForName(MeteorClientConnectionReadyNotification, object: nil, queue: nil) {
            note in
            // TODO: Need to connect after authenticating with fb, not just at app start
            if FBSession.openActiveSessionWithAllowLoginUI(false) {
                let accessToken = FBSession.activeSession().accessTokenData.accessToken
                let expiry = FBSession.activeSession().accessTokenData.expirationDate
                println("Will login to meteor with fb \(accessToken)")
                self.meteor.logonWithUserParameters(["fb-access": [
                    "accessToken": accessToken,
                    "expireAt": expiry.timeIntervalSince1970
                ]]) {
                    res, err in
                    println("res \(res) err \(err)")
                }
            }
        }
        

        
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActive()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    
    // DEBUGGING ONLY
    func debugCreateTestUser() {
        let user = User.MR_createEntity()
        user.firstName = "Tony";
        
        var photos : [Photo] = Array<Photo>()
        for index in 1...6 {
            let url = "https://s10.blob.core.windows.net/default/girl-00\(index).jpg"
            photos.append(Photo(url: url))
        }
        user.photos = photos
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
}
