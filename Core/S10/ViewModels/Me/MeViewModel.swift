//
//  MeViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import Meteor
import ReactiveCocoa

public struct MeViewModel {
    let meteor: MeteorService
    public let currentUser: User
    public let avatarURL: Dynamic<NSURL?>
    public let displayName: Dynamic<String>
    public let username: Dynamic<String>
    
    public init(meteor: MeteorService, currentUser: User) {
        self.meteor = meteor
        self.currentUser = currentUser
        avatarURL = currentUser.dynAvatar.map { $0?.url }
        displayName = currentUser.displayName
        username = currentUser.dynUsername.map { $0 ?? "" }
    }
}