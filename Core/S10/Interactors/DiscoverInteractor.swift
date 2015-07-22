//
//  DiscoverInteractor.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData
import Bond

public class DiscoverInteractor {
    public let candidates: DynamicArray<CandidateViewModel>
    
    public init() {
        // Filter out candidate without users for now
        candidates = User
            .by("\(UserKeys.candidateScore) != nil")
            .sorted(by: UserKeys.candidateScore.rawValue, ascending: false)
            .results(User).map { CandidateViewModel(user: $0) }
    }
    
    public func loadNextPage() {
    }
}
