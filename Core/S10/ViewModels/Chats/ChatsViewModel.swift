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
    public enum Section : Int {
        case Contacts = 0, New = 1
    }
    let meteor: MeteorService
    let taskService: TaskService
    let chatsSub: MeteorSubscription
    let messagesSub: MeteorSubscription
    let results: FetchedResultsArray<Connection>
    public let connections: DynamicArray<ConnectionViewModel>
    public let currentSection = MutableProperty<Section>(.Contacts)
    public let newUnreadCount = countOfUnreadConnections(cold: true)
    public let contactsUnreadCount = countOfUnreadConnections(cold: false)
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
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
        currentSection <~ chatsSub.ready.producer
            |> catch { _ in .empty }
            |> observeOn(UIScheduler())
            |> then(SignalProducer { observer, _ in
                let cold = countOfUnreadConnections(cold: true).value
                let warm = countOfUnreadConnections(cold: false).value
                if cold > 0 && warm == 0 {
                    sendNext(observer, .New)
                } else {
                    sendNext(observer, .Contacts)
                }
                sendCompleted(observer)
            })
        
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
        return ConversationViewModel(meteor: meteor, taskService: taskService, recipient: connection.otherUser)
    }
}
