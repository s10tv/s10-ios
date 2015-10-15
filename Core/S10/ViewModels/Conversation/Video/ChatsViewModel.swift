//
//  ChatsViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct ChatsViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    let chatsSub: MeteorSubscription
    let messagesSub: MeteorSubscription
    public let connections: FetchedResultsArray<ContactConnectionViewModel>
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
        chatsSub = meteor.subscribe("chats")
        messagesSub = meteor.subscribe("messages")
        connections = Connection
            .sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false)
            .results { ContactConnectionViewModel(connection: $0 as! Connection) }
    }
    
    public func conversationVM(index: Int) -> VideoConversationViewModel {
        let connection = connections[index].connection
        return VideoConversationViewModel(meteor: meteor, taskService: taskService, conversation: .Connection(connection))
    }
}
