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
    enum State {
        case Indeterminate, LoggedOut, LoggedIn, SignedUp
    }
    private let meteorService: MeteorService
    let digits = Digits.sharedInstance()
    let state: PropertyOf<State>
    
    init(meteorService: MeteorService) {
        self.meteorService = meteorService
        
        state = PropertyOf(.Indeterminate) {
            combineLatest(
                meteorService.account.producer,
                meteorService.user.producer,
                meteorService.settings.accountStatus.producer
            ) |> map { account, user, status in
                switch (account, user, status) {
                case (.None, _, _):
                    Log.info("Status - Logged Out")
                    return .LoggedOut
                case (.Some, .Some, .Some(.Pending)):
                    Log.info("Status - Logged In")
                    return .LoggedIn
                case (.Some, .Some, .Some(.Active)):
                    Log.info("Status - Signed Up")
                    return .SignedUp
                default:
                    Log.info("Status - Indeterminate")
                    return .Indeterminate
                }
            }
        }
    }
    
    private func didLogin() {
        // Allow this to be set by server rather than client
//        self.meteorService.meta.hasBeenWelcomed = false
//        self.meteorService.meta.gameTutorialMode = true
//        // TODO: Figure out whether user signed up or logged in
//        Analytics.track("Logged In")
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
                ).deliverOnMainThread().subscribeError({
                    subject.sendError($0)
                }, completed: {
                    self.didLogin()
                    subject.sendCompleted()
                })
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
