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

struct LoginViewModel {
    private let account: AccountService
    let loginButtonText: PropertyOf<String>
    let logoutButtonText: PropertyOf<String>
    let termsAndConditionURL = Globals.env.termsAndConditionURL
    let privacyURL = Globals.env.privacyURL
    
    init(account: AccountService) {
        self.account = account
        loginButtonText = account.digitsSession |> map {
            ($0?.phoneNumber).map {
                "Continue as \($0)"
            } ?? "Login with phone number"
        }
        logoutButtonText = account.digitsSession |> map {
            $0 != nil ? "Not you? Tap to logout." : ""
        }
    }

    func logout() {
        account.logout()
    }
}