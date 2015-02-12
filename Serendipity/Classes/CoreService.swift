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
import SugarRecord
import Meteor

class CoreService {
    
//        let urlStr = "ws://localhost:3000/websocket"
    let meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://s10.herokuapp.com/websocket"))
    let matchService : MatchService
    var mainContext : NSManagedObjectContext! {
        return meteor.mainQueueManagedObjectContext
    }
    var fbSession : FBSession {
        return FBSession.activeSession()!
    }
    var isRegistered : Bool {
        return meteor.hasAccount() || fbSession.state == .Open || fbSession.state == .OpenTokenExtended
    }
    
    init() {
        // Set up CoreData
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
        
        // Setup Meteor
        meteor.logDDPMessages = true
        meteor.connect()
        
        meteor.addSubscriptionWithName("currentUser")
        meteor.addSubscriptionWithName("connections")
        meteor.addSubscriptionWithName("messages")

        // Perform Login. TODO: Send fb access token if login otherwise expired
        // TODO: Need to connect after authenticating with fb, not just at app start
        if !meteor.hasAccount() && FBSession.openActiveSessionWithAllowLoginUI(false) {
            let data = FBSession.activeSession().accessTokenData
            meteor.loginWithFacebook(data.accessToken, expiresAt: data.expirationDate).subscribeError({ error in
                println("login error \(error)")
            }, completed: {
                println("login success")
            })
        }
        
        // Initialize other services
        matchService = MatchService(meteor: meteor)
        AzureClient.startWithMeteor(meteor)
    }
    
    func loginWithFacebook() {
        FBSession.openActiveSessionWithAllowLoginUI(true)
    }
    
    func logout() -> RACSignal {
        return meteor.logout().deliverOnMainThread().doCompleted({
            FBSession.activeSession().closeAndClearTokenInformation()
            self.mainContext.reset()
        }).replay()
    }
}