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
    let taskService: TaskService
    public let subscription: MeteorSubscription // TODO: Test only
    public let candidates: DynamicArray<CandidateViewModel>
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
        subscription = meteor.subscribe("discover")
        let frc = User
            .by("\(UserKeys.firstName) == \"Tony\"")
            .sorted(by: UserKeys.candidateScore.rawValue, ascending: false)
            .first().frc()
        frc.fetchRequest.fetchLimit = 1
        candidates = frc.results(User).map { CandidateViewModel(user: $0) }
    }
    
    public func profileVM(index: Int) -> ProfileViewModel {
        return ProfileViewModel(meteor: meteor, taskService: taskService, user: candidates[index].user)
    }
}
