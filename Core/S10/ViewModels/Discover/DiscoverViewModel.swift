//
//  DiscoverViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

public struct DiscoverViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    public let subscription: MeteorSubscription // TODO: Test only
    
    public let candidate: DynamicArray<CurrentCandidateViewModel>
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
        subscription = meteor.subscribe("candidate-discover")
        let frc = Candidate.by(CandidateKeys.status_, value: Candidate.Status.Active.rawValue).first().frc()
        candidate = frc.results(Candidate).map { CurrentCandidateViewModel(candidate: $0) }
    }
    
    public func profileVM() -> ProfileViewModel? {
        if candidate.count > 0 {
            return ProfileViewModel(meteor: meteor, taskService: taskService, user: candidate[0].user)
        }
        return nil
    }
    
    public func conversationVM() -> ConversationViewModel? {
        if candidate.count > 0 {
            return ConversationViewModel(meteor: meteor, taskService: taskService, recipient: candidate[0].user)
        }
        return nil
    }
}
