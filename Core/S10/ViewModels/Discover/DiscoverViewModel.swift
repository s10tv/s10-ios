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

public class DiscoverViewModel : NSObject {
    let meteor: MeteorService
    let taskService: TaskService
    let frc: NSFetchedResultsController
    public let subscription: MeteorSubscription // TODO: Test only
    
    public let candidate: MutableProperty<CurrentCandidateViewModel?>
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
        subscription = meteor.subscribe("candidate-discover")
        frc = Candidate.all()/*.by(CandidateKeys.status_, value: Candidate.Status.Active.rawValue)*/.first().frc()
        candidate = MutableProperty(nil)
        super.init()
        frc.delegate = self
        frc.performFetch(nil)
        controllerDidChangeContent(frc)
    }
    
    deinit {
        frc.delegate = nil
    }
    
    public func profileVM() -> ProfileViewModel? {
        return candidate.value.map { ProfileViewModel(meteor: meteor, taskService: taskService, user:$0.user) }
    }
}


// TODO: Establish better pattern for reactively finding a single element
// that does not require becoming delegate of NSFetchedResultsController
extension DiscoverViewModel : NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if let candidate = controller.fetchObjects().first as? Candidate {
            self.candidate.value = CurrentCandidateViewModel(candidate: candidate)
        } else {
            self.candidate.value = nil
        }
    }
}