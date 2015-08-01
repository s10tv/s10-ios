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

extension Digits {
    func authenticate() -> Future<DGTSession, NSError> {
        let promise = Promise<DGTSession, NSError>()
        authenticateWithCompletion { (session: DGTSession?, error: NSError?) in
            if let session = session {
                promise.success(session)
            } else if let error = error {
                promise.failure(error)
            } else {
                assertionFailure("Should either succeed or fail")
            }
        }
        return promise.future
    }
}

class AccountService {
    enum State {
        case Indeterminate, LoggedOut, LoggedIn, Onboarded
        
        var onboardingNeeded: Bool {
            switch self {
            case .Indeterminate, .Onboarded:
                return false
            case .LoggedOut, .LoggedIn:
                return true
            }
        }
    }
    private let meteorService: MeteorService
    private let _digitsSession: MutableProperty<DGTSession?>
    let digits = Digits.sharedInstance()
    let state: PropertyOf<State>
    let digitsSession: PropertyOf<DGTSession?>
    
    init(meteorService: MeteorService, settings: Settings) {
        self.meteorService = meteorService
        
        _digitsSession = MutableProperty(digits.session())
        digitsSession = PropertyOf(_digitsSession)
        state = PropertyOf(.Indeterminate) {
            combineLatest(
                meteorService.account.producer,
                meteorService.loggedIn.producer,
                settings.accountStatus.producer
            ) |> map { account, loggedIn, status in
                switch (account, loggedIn, status) {
                case (.None, _, _):
                    Log.info("Status - Logged Out")
                    return .LoggedOut
                case (.Some, true, .Some(.Pending)):
                    Log.info("Status - Logged In")
                    return .LoggedIn
                case (.Some, true, .Some(.Active)):
                    Log.info("Status - Signed Up")
                    return .Onboarded
                default:
                    Log.info("Status - Indeterminate")
                    return .Indeterminate
                }
            }
        }
    }
    
    func hasAccount() -> Bool {
        return digits.session() != nil && meteorService.account.value != nil
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
    
    func login() -> Future<(), NSError> {
        let promise = Promise<(), NSError>()
        digits.authenticate()
            |> deliverOn(UIScheduler())
            |> onComplete {
                self._digitsSession.value = $0.value
            println("Session userId= \($0.value?.userID) error \($0.error)")
            if let session = $0.value {
                self.meteorService.loginWithDigits(
                    userId: session.userID,
                    authToken: session.authToken,
                    authTokenSecret: session.authTokenSecret,
                    phoneNumber: session.phoneNumber
                ).subscribeError({
                    promise.failure($0)
                }, completed: {
                    self.didLogin()
                    promise.success()
                })
            } else {
                promise.failure($0.error!)
            }
        }
        return promise.future
    }
    
    func logout() {
        Analytics.track("Logged Out")
        Analytics.identifyUser(Globals.env.deviceId) // Reset to deviceId based tracking
        UD.resetAll()
        digits.logOut()
        _digitsSession.value = nil
        meteorService.logout()
    }
    
    func deleteAccount() -> RACSignal {
        digits.logOut()
        UD.resetAll()
        return meteorService.deleteAccount().deliverOnMainThread()
    }
}

extension AccountService : LoginDelegate {
    var loggedInPhone: PropertyOf<String?> {
        return _digitsSession |> map { $0?.phoneNumber }
    }
}
