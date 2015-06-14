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

class AccountService {
    private let meteorService: MeteorService
    private let readPerms = [
        "user_about_me",
        "user_photos",
        "user_location",
        "user_work_history",
        "user_education_history",
        "user_birthday",
        // extended permissions
        "email"
    ]
    var session: FBSession { return FBSession.activeSession() }
    
    init(meteorService: MeteorService) {
        self.meteorService = meteorService
        openSession(allowUI: false)
    }
    
    // TODO: Attach persistent FBSessionStateHandler rather than one off completion
    private func openSession(#allowUI: Bool) -> RACSignal {
        return FBSession.openActiveSession(readPermissions: readPerms, allowLoginUI: allowUI)
    }
    
    private func didLogin() {
        // Allow this to be set by server rather than client
        self.meteorService.meta.hasBeenWelcomed = false
        self.meteorService.meta.gameTutorialMode = true
        // TODO: Figure out whether user signed up or logged in
        Analytics.track("Logged In")
    }
    
    // MARK: -
    
    func debugLogin(userId: String) -> RACSignal {
        return meteorService.debugLoginWithUserId(userId).replayWithSubject().deliverOnMainThread().doCompleted {
            self.didLogin()
        }
    }
    
    func login() -> RACSignal {
        return self.openSession(allowUI: true).then {
            let data = self.session.accessTokenData
            return self.meteorService.loginWithFacebook(accessToken: data.accessToken, expiresAt: data.expirationDate)
        }.replayWithSubject().deliverOnMainThread().doCompleted {
            self.didLogin()
        }
    }
    
    func logout() -> RACSignal {
        Analytics.track("Logged Out")
        Analytics.identifyUser(Globals.env.deviceId) // Reset to deviceId based tracking
        self.session.closeAndClearTokenInformation()
        UD.resetAll()
        return meteorService.logout().deliverOnMainThread()
    }
    
    func deleteAccount() -> RACSignal {
        self.session.closeAndClearTokenInformation()
        UD.resetAll()
        return meteorService.deleteAccount().deliverOnMainThread()
    }
}
