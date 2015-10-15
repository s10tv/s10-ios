//
//  DiscoverViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import LayerKit
import ReactiveCocoa

public struct DiscoverViewModel {
    let ctx: Context
    public let subscription: MeteorSubscription // TODO: Test only
    
    public let candidate: FetchedResultsArray<TodayViewModel>
    
    public init(ctx: Context) {
        self.ctx = ctx
        subscription = ctx.meteor.subscribe("candidate-discover")
        candidate = Candidate
            .by(CandidateKeys.status_, value: Candidate.Status.Active.rawValue)
            .first()
            .results { TodayViewModel(candidate: $0 as! Candidate, currentUser: ctx.meteor.currentUser) }
    }
    
    public func profileVM() -> ProfileViewModel? {
        if candidate.count > 0 {
            return ProfileViewModel(ctx, user: candidate[0].user, timeRemaining: candidate[0].timeRemaining)
        }
        return nil
    }
    
    public func conversationVM() -> ConversationViewModel {
        let conversation = ctx.layer.conversationWithUser(candidate[0].user)
        return ConversationViewModel(ctx, conversation: conversation)
    }
    
}
