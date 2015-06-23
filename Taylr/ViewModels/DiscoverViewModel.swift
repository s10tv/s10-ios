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
    let sections: DynamicArray<DynamicArray<NSManagedObject>>
    
    init() {
        frc = Candidate.sorted(by: CandidateAttributes.score.rawValue, ascending: false).frc()
        frc.performFetch(nil)
        sections = frc.dynSections
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> Candidate {
        return sections[indexPath.section][indexPath.row] as! Candidate
    }
    
    func loadNextPage() {
    }
}
