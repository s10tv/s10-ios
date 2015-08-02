//
//  LoginViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/31/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import DigitsKit

public protocol LoginDelegate {
    var loggedInPhone: PropertyOf<String?> { get }
    func logout()
    func login() -> Future<(), NSError>
}

public struct LoginViewModel {
    private let delegate: LoginDelegate
    public let loginButtonText: PropertyOf<String>
    public let logoutButtonText: PropertyOf<String>
    public let termsAndConditionURL = NSURL("http://taylrapp.com/terms")
    public let privacyURL = NSURL("http://taylrapp.com/privacy")
    public let loginAction: Action<AnyObject, (), ErrorAlert>
    public let logoutAction: Action<AnyObject, (), NoError>
    
    public init(delegate: LoginDelegate) {
        self.delegate = delegate
        loginButtonText = delegate.loggedInPhone |> map {
            $0.map {
                "Continue as \($0)"
            } ?? "Login with phone number"
        }
        logoutButtonText = delegate.loggedInPhone |> map {
            $0 != nil ? "Not you? Tap to logout." : ""
        }
        loginAction = Action { _ in
//            return Future(error: ErrorAlert(title: "Unable to login"))
            return delegate.login()
                |> deliverOn(UIScheduler())
                |> mapError { e in
                    ErrorAlert(title: "Unable to login", message: e.localizedDescription, underlyingError: e)
                }
        }
        logoutAction = Action { _ in
            Future(value: delegate.logout())
        }
    }
}