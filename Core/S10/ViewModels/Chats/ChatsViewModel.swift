//
//  ChatsViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

func countOfUnreadConnections(#cold: Bool) -> PropertyOf<Int> {
    let pred = NSPredicate(format: "%K == %@ && %K > 0",
        ConnectionKeys.cold.rawValue, cold,
        ConnectionKeys.unreadCount.rawValue)
    return PropertyOf(0, SignalProducer<Int, NoError> { sink, disposable in
        let results = Connection.by(pred).results(Connection)
        let bond = Bond<Int> { sendNext(sink, $0) }
        results.dynCount.bindTo(bond)
        disposable.addDisposable {
            let retainedResults = results
            let retainedBond = bond
        }
    })
}

public struct ChatsViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    let chatsSub: MeteorSubscription
    let messagesSub: MeteorSubscription
    let results: FetchedResultsArray<Connection>
    public let connections: DynamicArray<ContactConnectionViewModel>
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
        chatsSub = meteor.subscribe("chats")
        messagesSub = meteor.subscribe("messages")
        results = Connection
            .by(NSPredicate(format: "%K != nil", ConnectionKeys.otherUser.rawValue))
            .sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false)
            .results(Connection)
        connections = results.map { ContactConnectionViewModel(connection: $0) }
    }
    
    public func conversationVM(index: Int) -> ConversationViewModel {
        let connection = connections[index].connection
        return ConversationViewModel(meteor: meteor, taskService: taskService, recipient: connection.otherUser)
    }
}
