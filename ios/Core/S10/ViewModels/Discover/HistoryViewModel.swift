//
//  HistoryViewModel.swift
//  S10
//
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct HistoryViewModel {
    let ctx: Context
    let subscription: MeteorSubscription
    public let candidates: FetchedResultsArray<CandidateViewModel>
    
    public init(_ ctx: Context) {
        self.ctx = ctx
        subscription = ctx.meteor.subscribe("candidate-discover")
        candidates = Candidate
            .sorted(by: CandidateKeys.date.rawValue, ascending: false)
            .results { CandidateViewModel(candidate: $0 as! Candidate) }
    }
    
    public func profileVM(index: Int) -> ProfileViewModel? {
        return ProfileViewModel(ctx, user: candidates[index].user)
    }
}
