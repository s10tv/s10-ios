//
//  DiscoverViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public struct DiscoverViewModel {
    let meteor: MeteorService
    let subscription: MeteorSubscription
    public let candidates: DynamicArray<CandidateViewModel>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        subscription = meteor.subscribe("discover")
        candidates = User
            .by("\(UserKeys.candidateScore) != nil")
            .sorted(by: UserKeys.candidateScore.rawValue, ascending: false)
            .results(User).map { CandidateViewModel(user: $0) }
    }
    
    public func profileVM(index: Int) -> ProfileViewModel {
        return ProfileViewModel(meteor: meteor, user: candidates[index].user)
    }
}
