//
//  MeViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public class MeViewModel {
    public let currentUser: User
    public let avatarURL: Dynamic<NSURL?>
    public let displayName: Dynamic<String>
    
    public init(_ currentUser: User) {
        self.currentUser = currentUser
        avatarURL = currentUser.avatarURL
        displayName = currentUser.displayName
    }
}