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

public struct TodayViewModel {
    let user: User
    public let cover: Image?
    public let avatar: Image?
    public let displayName: String
    public let hometown: String
    public let major: String
    public let reason: String
    public let profileIcons: DynamicArray<Image>
    public let timeRemaining: PropertyOf<String?>
    public let fractionRemaining: PropertyOf<CGFloat>
    
    init(candidate: Candidate, settings: Settings) {
        user = candidate.user
        cover = user.cover
        avatar = user.avatar
        hometown = user.hometown ?? ""
        major = user.major ?? ""
        displayName = user.pDisplayName().value
        reason = candidate.reason
        profileIcons = DynamicArray(user.connectedProfiles.map { $0.icon })
        timeRemaining = PropertyOf(Formatters.formatInterval(settings.nextMatchDate.value))
        fractionRemaining = PropertyOf(0.25)
    }
}
