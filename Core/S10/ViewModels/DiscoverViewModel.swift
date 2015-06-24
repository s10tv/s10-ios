//
//  DiscoverViewModel.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData
import Bond

public class DiscoverViewModel {
    private let frc: NSFetchedResultsController
    public let candidates: DynamicArray<Candidate>
    
    public init() {
        // Filter out candidate without users for now
        frc = Candidate.by("\(CandidateKeys.user) != nil").sorted(by: CandidateKeys.score.rawValue, ascending: false).frc()
        candidates = frc.dynSections[0].map { (o, _) in o as! Candidate }
    }
    
    public func loadNextPage() {
    }
}
