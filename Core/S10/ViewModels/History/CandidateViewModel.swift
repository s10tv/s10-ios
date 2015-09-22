//
//  CandidateViewModel.swift
//  S10
//
//  Created by Tony Xiao on 9/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

public struct CandidateViewModel {
    let user: User
    public let avatar: Image?
    public let displayName: String
    public let reason: String
    public let profileIcons: DynamicArray<Image>
    
    init(candidate: Candidate) {
        user = candidate.user
        reason = candidate.reason
        avatar = user.avatar
        displayName = user.pDisplayName().value
        profileIcons = DynamicArray(user.connectedProfiles.map { $0.icon })
    }
}