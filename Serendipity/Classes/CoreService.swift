//
//  CoreService.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/3/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import ReactiveCocoa
import FacebookSDK
import MagicalRecord
import Meteor

class CoreService {
    
//        let urlStr = "ws://localhost:3000/websocket"
    let meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://s10.herokuapp.com/websocket"))
    
    init() {
        // Set up CoreData
        NSValueTransformer.setValueTransformer(PhotosValueTransformer(), forName: "PhotosValueTransformer")
        NSPersistentStoreCoordinator.MR_setDefaultStoreCoordinator(meteor.persistentStoreCoordinator)
        NSManagedObjectContext.MR_setDefaultContext(meteor.mainQueueManagedObjectContext)
        
        // Setup Meteor
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "METShouldLogDDPMessages")
        meteor.connect()
        // TODO: Make this more modular, let MatchService add its own subscription?
        let sub = meteor.addSubscriptionWithName("currentUser")

        meteor.addSubscriptionWithName("connections")
        meteor.addSubscriptionWithName("messages")
        sub.whenDone { (err) -> Void in
            println("UserID \(self.meteor.userID)")
            let user = User.currentUser()
            //            println("first \(user.photos?.map { $0.url })")
            println("first \(user.firstName) \(user.photos)")
        }

        // Perform Login. TODO: Send fb access token if login otherwise expired
        // TODO: Need to connect after authenticating with fb, not just at app start
        if !meteor.hasAccount() && FBSession.openActiveSessionWithAllowLoginUI(false) {
            let data = FBSession.activeSession().accessTokenData
            let userParam = [["fb-access": [
                "accessToken": data.accessToken,
                "expireAt": data.expirationDate.timeIntervalSince1970
            ]]]
            meteor.loginWithMethodName("login", parameters: userParam, completionHandler: { err in
                println("Logged in with error? \(err)")
            })
        }
        MatchService.startWithMeteor(meteor)
        AzureClient.startWithMeteor(meteor)
    }
}