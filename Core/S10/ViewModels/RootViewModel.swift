//
//  RootViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import CoreData
import ReactiveCocoa
import Bond

public struct RootViewModel {
    let unreadConversations: FetchedResultsArray<Connection>
    public let unreadConnectionsCount: PropertyOf<Int>
    
    public init() {
        unreadConversations = Connection
            .by(NSPredicate(format: "%K > 0", ConnectionKeys.unreadCount.rawValue))
            .results(Connection)
        unreadConnectionsCount = fromBondDynamic(unreadConversations.dynCount)
    }
}
