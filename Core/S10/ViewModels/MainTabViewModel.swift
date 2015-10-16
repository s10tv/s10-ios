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

public struct MainTabViewModel {
    let ctx: Context
    let unreadConversations: FetchedResultsArray<Connection>
    
    public let chatsBadge: PropertyOf<String?>
    
    public init(_ ctx: Context) {
        self.ctx = ctx
        unreadConversations = Connection
            .by(NSPredicate(format: "%K > 0", ConnectionKeys.unreadCount.rawValue))
            .results { $0 as! Connection }
        chatsBadge = ctx.layer.unreadCount.map { $0 > 0 ? "\($0)" : nil }
    }
}