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
//    func login()
}

public struct LoginViewModel {
    private let delegate: LoginDelegate
    public let loginButtonText: PropertyOf<String>
    public let logoutButtonText: PropertyOf<String>
    public let termsAndConditionURL = NSURL("http://taylrapp.com/terms")
    public let privacyURL = NSURL("http://taylrapp.com/privacy")
    
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
    }

    public func logout() {
        delegate.logout()
    }
}