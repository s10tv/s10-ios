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
    public enum Section : Int {
        case Contacts = 0, New = 1
    }
    let meteor: MeteorService
    let chatsSub: MeteorSubscription
    let messagesSub: MeteorSubscription
    let results: FetchedResultsArray<Connection>
    public let connections: DynamicArray<ConnectionViewModel>
    public let currentSection = MutableProperty<Section>(.Contacts)
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        chatsSub = meteor.subscribe("chats")
        messagesSub = meteor.subscribe("messages")
        results = Connection
            .by(NSPredicate(format: "%K != nil && %K == true",
                ConnectionKeys.otherUser.rawValue, ConnectionKeys.cold.rawValue))
            .sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false)
            .results(Connection)
        connections = results
            .map { (connection: Connection) -> ConnectionViewModel in
                if connection.cold?.boolValue == true {
                    return NewConnectionViewModel(connection: connection)
                } else {
                    return ContactConnectionViewModel(connection: connection)
                }
            }

        (currentSection
            |> map {
                switch $0 {
                case .Contacts:
                    return NSPredicate(format: "%K != nil && %K == false",
                        ConnectionKeys.otherUser.rawValue, ConnectionKeys.cold.rawValue)
                case .New:
                    return NSPredicate(format: "%K != nil && %K == true",
                        ConnectionKeys.otherUser.rawValue, ConnectionKeys.cold.rawValue)
                }
            }) ->> results.predicateBond
    }
    
    public func conversationVM(index: Int) -> ConversationViewModel {
        var connection: Connection!
        if let vm = connections[index] as? NewConnectionViewModel {
            connection = vm.connection
        }
        if let vm = connections[index] as? ContactConnectionViewModel {
            connection = vm.connection
        }
        return ConversationViewModel(meteor: meteor, recipient: connection.otherUser)
    }
}
