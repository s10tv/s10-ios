//
//  DiscoverViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct DiscoverViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    public let subscription: MeteorSubscription // TODO: Test only
    
    public let candidate: FetchedResultsArray<TodayViewModel>
    
    public init(meteor: MeteorService, taskService: TaskService, settings: Settings) {
        self.meteor = meteor
        self.taskService = taskService
        subscription = meteor.subscribe("candidate-discover")
        candidate = Candidate
            .by(CandidateKeys.status_, value: Candidate.Status.Active.rawValue)
            .first()
            .results { TodayViewModel(candidate: $0 as! Candidate, settings: settings) }
    }
    
    public func profileVM() -> ProfileViewModel? {
        if candidate.count > 0 {
            return ProfileViewModel(meteor: meteor, taskService: taskService, user: candidate[0].user, timeRemaining: candidate[0].timeRemaining)
        }
        return nil
    }
    
    public func conversationVM() -> ConversationViewModel? {
        if candidate.count > 0 {
            return ConversationViewModel(meteor: meteor, taskService: taskService, conversation: .User(candidate[0].user))
        }
        return nil
    }
}
