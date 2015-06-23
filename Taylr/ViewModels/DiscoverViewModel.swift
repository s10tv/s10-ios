//
//  DiscoverViewModel.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData
import Core
import Bond

class DiscoverViewModel {
    private let frc: NSFetchedResultsController
    let candidates: DynamicArray<Candidate>
    
    init() {
        frc = Candidate.sorted(by: CandidateAttributes.score.rawValue, ascending: false).frc()
        frc.performFetch(nil)
        candidates = frc.dynSections[0].map { (o, _) in o as! Candidate }
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> Candidate {
        return candidates[indexPath.row]
    }
    
    func loadNextPage() {
    }
}
