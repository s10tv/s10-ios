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
    public let user: User
    public let avatarURL: Dynamic<NSURL?>
    public let avatar: Dynamic<Image?>
    public let displayName: Dynamic<String>
    public let distance: Dynamic<String>
    public let jobTitle: PropertyOf<String>
    public let employer: PropertyOf<String>
    
    public init(user: User) {
        self.user = user
        avatar = user.dynAvatar
        avatarURL = user.dynAvatar.map { $0?.url }
        displayName = user.displayName
        distance = user.dynDistance.map { $0.flatMap { Formatters.formatDistance($0) } ?? "" }
        jobTitle = user.dynJobTitle |> map { $0 ?? "" }
        employer = user.dynEmployer |> map { $0 ?? "" }
    }
}