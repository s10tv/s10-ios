//
//  CandidateViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct TodayViewModel {
    let user: User
    public let cover: Image?
    public let avatar: Image?
    public let displayName: String
    public let hometown: String
    public let major: String
    public let reason: String
    public let profileIcons: ArrayProperty<Image>
    public let timeRemaining: ProducerProperty<String>
    public let fractionRemaining: PropertyOf<CGFloat>
    
    init(candidate: Candidate, currentUser: CurrentUser) {
        user = candidate.user
        cover = user.cover
        avatar = user.avatar
        hometown = user.hometown ?? ""
        major = user.major ?? ""
        displayName = user.pDisplayName().value
        reason = candidate.reason
        profileIcons = ArrayProperty(user.connectedProfiles.map { $0.icon })
        // TODO: There are memory management issues related to PropertyOf
        // that takes a signalProducer. ProducerProperty seems to solve it
        timeRemaining = ProducerProperty(combineLatest(
            CurrentTime.producer,
            currentUser.nextMatchDate.producer
        ).map { currentTime, nextMatchDate in
            let interval = max(Int((nextMatchDate ?? NSDate()).timeIntervalSinceDate(currentTime)), 0)
            let hours = interval / 3600
            let minutes = (interval - hours * 3600) / 60
            let seconds = interval - hours * 3600 - minutes * 60
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        })
        fractionRemaining = PropertyOf(0.5)
    }
}
