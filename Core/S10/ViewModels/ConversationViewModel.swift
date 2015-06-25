//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public class ConversationViewModel {
    private let messagesFrc: NSFetchedResultsController
    public let connection: Connection
    public let recipient: Dynamic<User?>
    public let formattedStatus: Dynamic<String>
    public let unreadCount: Dynamic<Int>
    public private(set) lazy var messageViewModels: DynamicArray<MessageViewModel> = {
        return self.messagesFrc.dynSections[0].map { (o, _) in MessageViewModel(message: o as! Message) }
    }()
    
    public init(connection: Connection) {
        self.connection = connection
        messagesFrc = connection.fetchMessages(sorted: true)
        recipient = connection.dynOtherUser
        unreadCount = connection.dynUnreadCount.map { $0 ?? 0 }
        formattedStatus = ConversationViewModel.formatStatus(connection)
    }
    
    class func formatStatus(connection: Connection) -> Dynamic<String> {
        let formattedAction: Dynamic<String?> = reduce(connection.dynLastMessageStatus, connection.dynOtherUser, connection.dynLastSender) {
            if let status = $0, let otherUser = $1, let lastSender = $2 {
                let receivedLast = (otherUser == lastSender)
                switch status {
                case .Sent: return receivedLast ? "Received" : "Sent"
                case .Opened: return receivedLast ? "Received" : "Opened"
                case .Expired: return receivedLast ? "Received" : "Opened"
                default: break
                }
            }
            return nil
        }
        let formattedDate: Dynamic<String?> = reduce(connection.dynUpdatedAt, CurrentDate) {
            Formatters.formatRelativeDate($0, relativeTo: $1)
        }
        return reduce(formattedAction, formattedDate) {
            if let action = $0, let date = $1 {
                return "\(action) \(date)"
            }
            return ""
        }
    }
}
