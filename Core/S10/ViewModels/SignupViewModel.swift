//
//  SignupViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/2/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public class SignupViewModel {
    let user: User
    public let firstName = Dynamic("")
    public let lastName = Dynamic("")
    public let username = Dynamic("")
    public let about = Dynamic("")
    
    public init(user: User) {
        self.user = user
        user.dynFirstName.map { $0 ?? "" } ->> firstName
        user.dynLastName.map { $0 ?? "" } ->> lastName
        user.dynUsername.map { $0 ?? "" } ->> username
        user.dynAbout.map { $0 ?? "" } ->> about
    }
}