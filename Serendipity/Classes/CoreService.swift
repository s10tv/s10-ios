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
    
    init() {
        // Set up CoreData
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
        
        // Setup Meteor
        meteor.logDDPMessages = true
        meteor.connect()
        
        meteor.addSubscriptionWithName("currentUser")
        meteor.addSubscriptionWithName("connections")
        meteor.addSubscriptionWithName("messages")
        
        // Initialize other services
        matchService = MatchService(meteor: meteor)
        AzureClient.startWithMeteor(meteor)
    }
    
    private func loginToMeteor() {
        let data = FBSession.activeSession().accessTokenData
        meteor.loginWithFacebook(data.accessToken, expiresAt: data.expirationDate).subscribeError({ error in
            println("login error \(error)")
        }, completed: {
            println("login success")
        })
    }
    
    private let fbReadPerms = ["public_profile"]
    
    func attemptLoginWithCachedCredentials() -> Bool {
        if meteor.hasAccount() {
            return true
        }
        if FBSession.openActiveSession(readPermissions: fbReadPerms) {
            loginToMeteor()
            return true
        }
        return false
    }
    
    func loginWithUI() -> RACSignal {
        return FBSession.openActiveSessionWithUI(readPermissions: fbReadPerms).deliverOnMainThread().doCompleted {
            self.loginToMeteor()
        }.replay()
    }
    
    func logout() -> RACSignal {
        return meteor.logout().deliverOnMainThread().doCompleted({
            FBSession.activeSession().closeAndClearTokenInformation()
            self.mainContext.reset()
        }).replay()
    }
}