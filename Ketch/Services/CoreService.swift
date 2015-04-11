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

class CoreService : NSObject {
    var flow: FlowService!
    var meteorService: MeteorService!
    private var meteor : METCoreDataDDPClient!
    var meta: MetadataService!
    var mainContext : NSManagedObjectContext! {
        return meteor.mainQueueManagedObjectContext
    }
    var fbSession : FBSession {
        return FBSession.activeSession()!
    }
    
    override init() {
        super.init()
        meteorService = MeteorService(serverURL: Env.serverURL)
        meta = MetadataService(collection: meteorService.collections.metadata)
        meteor = meteorService.meteor
        
        flow = FlowService(meteorService: meteorService, metadataService: meta)
        
        attemptLoginWithCachedCredentials()
    }
    
    private func loginToMeteor() {
        let data = FBSession.activeSession().accessTokenData
        meteor.loginWithFacebook(data.accessToken, expiresAt: data.expirationDate)
    }
    
    // TODO: What permissions do we actually need?
    private let fbReadPerms = [
        "user_about_me",
        "user_photos",
        "user_location",
        "user_work_history",
        "user_education_history",
        "user_birthday",
        // extended permissions
        "email"]
    
    func attemptLoginWithCachedCredentials() -> Bool {
        if meteorService.account != nil {
            return true
        }
        if FBSession.openActiveSession(readPermissions: fbReadPerms) {
            loginToMeteor()
            return true
        }
        NC.postNotification(.DidFailLoginToMeteor)
        return false
    }
    
    func addPushToken(pushTokenData: NSData) {
        // TODO: Only call this after user logged in
        if let apsEnv = Env.provisioningProfile?.apsEnvironment?.rawValue {
            meteor.callMethod("user/addPushToken", params: [Env.appID, apsEnv, pushTokenData.hexString()])
        }
    }
    
    func loginWithUI() -> RACSignal {
        return FBSession.openActiveSessionWithUI(readPermissions: fbReadPerms).deliverOnMainThread().doCompleted {
            self.loginToMeteor()
        }.replay()
    }
    
    func logout() -> RACSignal {
        FBSession.activeSession().closeAndClearTokenInformation()
        mainContext.reset()
        UD.resetAll()
        return meteor.logout().deliverOnMainThread() // TODO: Log out needs to reset the METDatabase
    }
}
