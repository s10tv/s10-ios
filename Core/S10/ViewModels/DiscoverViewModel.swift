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
    let unreadConversations: FetchedResultsArray<Connection>
    public let candidates: DynamicArray<CandidateViewModel>
    public let unreadConnectionsCount: Dynamic<Int>
    
    public init() {
        // Filter out candidate without users for now
        candidates = Candidate
//            .by("\(CandidateKeys.user) != nil")
            .sorted(by: CandidateKeys.score.rawValue, ascending: false)
            .results(Candidate).map { CandidateViewModel(user: $0.user) }
        unreadConversations = Connection
            .by(NSPredicate(format: "%K > 0", ConnectionKeys.unreadCount.rawValue))
            .results(Connection)
        unreadConnectionsCount = unreadConversations.dynCount
    }
    
    public func loadNextPage() {
    }
}
