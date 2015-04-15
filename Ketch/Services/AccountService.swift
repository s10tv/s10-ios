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
    
    // MARK: -
    
    func login() -> RACSignal {
        return self.openSession(allowUI: true).then {
            let data = self.session.accessTokenData
            return self.meteorService.loginWithFacebook(accessToken: data.accessToken, expiresAt: data.expirationDate)
        }.replayWithSubject().deliverOnMainThread().doCompleted {
            // Allow this to be set by server rather than client
            self.meteorService.meta.hasBeenWelcomed = false
            self.meteorService.meta.gameTutorialMode = true
            // TODO: Figure out whether user signed up or logged in
            Analytics.loggedIn()
        }
    }
    
    func logout() -> RACSignal {
        Analytics.loggedOut()
        self.session.closeAndClearTokenInformation()
        UD.resetAll()
        return meteorService.logout().deliverOnMainThread()
    }
}
