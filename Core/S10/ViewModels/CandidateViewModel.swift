//
//  CandidateViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public struct CandidateViewModel {
    public let user: User?
    public let avatarURL: Dynamic<NSURL?>
    public let displayName: Dynamic<String>
    
    public init(user: User?) {
        self.user = user
        avatarURL = user?.avatarURL ?? Dynamic(nil)
        displayName = user?.displayName ?? Dynamic("")
    }
}