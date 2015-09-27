//
//  HistoryViewModel.swift
//  S10
//
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

public struct HistoryViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    let subscription: MeteorSubscription
    public let candidates: FetchedResultsArray<CandidateViewModel>
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
        subscription = meteor.subscribe("candidate-discover")
        candidates = Candidate
            .sorted(by: CandidateKeys.date.rawValue, ascending: false)
            .results { CandidateViewModel(candidate: $0 as! Candidate) }
    }
    
    public func profileVM(index: Int) -> ProfileViewModel? {
        return ProfileViewModel(meteor: meteor, taskService: taskService, user: candidates[index].user)
    }
}
