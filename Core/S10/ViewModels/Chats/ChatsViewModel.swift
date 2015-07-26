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

public struct ChatsViewModel {
    let meteor: MeteorService
    let chatsSub: MeteorSubscription
    let messagesSub: MeteorSubscription
    public let contactsConnections: DynamicArray<ContactConnectionViewModel>
    public let newConnections: DynamicArray<NewConnectionViewModel>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        chatsSub = meteor.subscribe("chats")
        messagesSub = meteor.subscribe("messages")
        contactsConnections = Connection
            .by("\(ConnectionKeys.otherUser) != nil && \(ConnectionKeys.cold) == false")
            .sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false)
            .results(Connection)
            .map { ContactConnectionViewModel(connection: $0) }
        newConnections = Connection
            .by("\(ConnectionKeys.otherUser) != nil && \(ConnectionKeys.cold) == true")
            .sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false)
            .results(Connection)
            .map { NewConnectionViewModel(connection: $0) }
    }
    
    public func conversationVM(index: Int) -> ConversationViewModel {
        return ConversationViewModel(meteor: meteor, recipient: contactsConnections[index].connection.otherUser)
    }
}
