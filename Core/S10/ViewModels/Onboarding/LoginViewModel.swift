//
//  LoginViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/31/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public protocol LoginDelegate {
    var loggedInPhone: PropertyOf<String?> { get }
    func logout()
    func login() -> Future<AccountState, NSError>
}

public enum AccountState : String {
    case Indeterminate = "Indeterminate"
    case LoggedOut = "LoggedOut"
    case LoggedIn = "LoggedIn"
    case Onboarded = "Onboarded"
    
    public var onboardingNeeded: Bool {
        switch self {
        case .Indeterminate, .Onboarded:
            return false
        case .LoggedOut, .LoggedIn:
            return true
        }
    }
}
// TODO: make delegate weak
public struct LoginViewModel {
    private let delegate: LoginDelegate
    public let loginButtonText: PropertyOf<String>
    public let logoutButtonText: PropertyOf<String>
    public let termsAndConditionURL = NSURL("http://www.taylrapp.com/terms")
    public let privacyURL = NSURL("http://www.taylrapp.com/privacy")
    public let loginAction: Action<AnyObject, AccountState, ErrorAlert>
    public let logoutAction: Action<AnyObject, (), NoError>
    
    public init(meteor: MeteorService, delegate: LoginDelegate) {
        self.delegate = delegate
        loginButtonText = delegate.loggedInPhone |> map {
            $0.map {
                "Continue as \($0)"
            } ?? "Login with phone number"
        }
        logoutButtonText = delegate.loggedInPhone |> map {
            $0 != nil ? "Not you? Tap to logout." : ""
        }
        loginAction = Action { _ -> Future<AccountState, ErrorAlert> in
            if meteor.offline { return Future(error: eOffline) }
            return delegate.login()
                |> deliverOn(UIScheduler())
                |> mapError { e in
                    ErrorAlert(title: "Unable to login", message: e.localizedFailureReason, underlyingError: e)
                }
        }
        logoutAction = Action { _ in
            Future(value: delegate.logout())
        }
    }
}