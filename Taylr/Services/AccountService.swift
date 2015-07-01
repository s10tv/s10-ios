//
//  AccountService.swift
//  Taylr
//
//  Created by Tony Xiao on 2/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import DigitsKit
import Core

class AccountService {
    private let meteorService: MeteorService

    let digits = Digits.sharedInstance()
    
    init(meteorService: MeteorService) {
        self.meteorService = meteorService
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
        let subject = RACReplaySubject()
        digits.authenticateWithCompletion { (session: DGTSession?, error: NSError?) in
            println("Session userId= \(session?.userID) error \(error)")
            if let session = session {
                self.meteorService.loginWithDigits(
                    userId: session.userID,
                    authToken: session.authToken,
                    authTokenSecret: session.authTokenSecret,
                    phoneNumber: session.phoneNumber
                ).doCompleted {
                    self.didLogin()
                }.subscribe(subject)
            } else {
                subject.sendError(error)
            }
        }
        return subject
    }
    
    func logout() -> RACSignal {
        Analytics.track("Logged Out")
        Analytics.identifyUser(Globals.env.deviceId) // Reset to deviceId based tracking
        UD.resetAll()
        digits.logOut()
        return meteorService.logout().deliverOnMainThread()
    }
    
    func deleteAccount() -> RACSignal {
        digits.logOut()
        UD.resetAll()
        return meteorService.deleteAccount().deliverOnMainThread()
    }
}
