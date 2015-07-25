//
//  CandidateViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import ReactiveCocoa

public struct CandidateViewModel {
    let user: User
    public let avatar: Image?
    public let displayName: String
    public let jobTitle: String
    public let employer: String
    public let profileIcons: DynamicArray<Image>
    
    init(user: User) {
        self.user = user
        avatar = user.avatar
        displayName = user.pDisplayName().value
        jobTitle = user.jobTitle ?? ""
        employer = user.employer ?? ""
        profileIcons = DynamicArray(user.connectedProfiles.map { $0.icon })
    }
}