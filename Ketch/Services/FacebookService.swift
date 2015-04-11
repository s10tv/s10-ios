//
//  FacebookService.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/3/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import ReactiveCocoa
import FacebookSDK

class FacebookService {

    let meteorService: MeteorService
    var fbSession : FBSession {
        return FBSession.activeSession()!
    }
    
    init(meteorService: MeteorService) {
        self.meteorService = meteorService
        attemptLoginWithCachedCredentials()
    }
    
    private func loginToMeteor() {
        let data = FBSession.activeSession().accessTokenData
        meteorService.loginWithFacebook(accessToken: data.accessToken, expiresAt: data.expirationDate)
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
        return false
    }
    
    func loginWithUI() -> RACSignal {
        return FBSession.openActiveSessionWithUI(readPermissions: fbReadPerms).deliverOnMainThread().doCompleted {
            self.loginToMeteor()
        }.replay()
    }
    
    func logout() -> RACSignal {
        FBSession.activeSession().closeAndClearTokenInformation()
        // TODO: These Doesn't really belong here
        meteorService.mainContext.reset()
        UD.resetAll()
        return meteorService.logout().deliverOnMainThread() // TODO: Log out needs to reset the METDatabase
    }
}
