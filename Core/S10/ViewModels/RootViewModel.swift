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

public struct RootNavViewModel {
    let prefetchedSubscriptions: [MeteorSubscription]
    public init(meteor: MeteorService) {
        // Subscriptions which are globally useful that we are gonna try to fetch asap
        // so that there's content to show immediately
        prefetchedSubscriptions = [
            meteor.subscribe("me"),
            meteor.subscribe("discover"),
            meteor.subscribe("chats"),
            meteor.subscribe("integrations")
        ]
    }
}

public struct RootTabViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    let unreadConversations: FetchedResultsArray<Connection>
    
    public let chatsBadge: PropertyOf<String?>
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
        unreadConversations = Connection
            .by(NSPredicate(format: "%K > 0", ConnectionKeys.unreadCount.rawValue))
            .results { $0 as! Connection }
        chatsBadge = unreadConversations.count.map { $0 > 0 ? "\($0)" : nil }
    }
}