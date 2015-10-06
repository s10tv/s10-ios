//
//  Conversation.swift
//  S10
//
//  Created by Tony Xiao on 10/5/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SugarRecord
import RealmSwift

enum Conversation {
    case User(Core.User)
    case Connection(Core.Connection)
    
    var messagesFinder: SugarRecordFinder {
        switch self {
        case .Connection(let connection):
            return Message.by(MessageKeys.connection.rawValue, value: connection)
        case .User(let user):
            return Message.by(MessageKeys.sender.rawValue, value: user)
        }
    }
    
    var id: RecipientId {
        switch self {
        case .Connection(let connection): return .ConnectionId(connection.documentID!)
        case .User(let user): return .UserId(user.documentID!)
        }
    }
    
    var user: Core.User? {
        switch self {
        case .Connection(let connection): return connection.otherUser
        case .User(let user): return user
        }
    }
    
    var connection: Core.Connection? {
        switch self {
        case .Connection(let connection): return connection
        case .User(let user): return user.connection
        }
    }
    
    var serverStatus: String {
        if let connection = connection,
            let status = connection.lastMessageStatus {
                let receivedLast = (connection.otherUser == connection.lastSender)
                let formattedDate = Formatters.formatRelativeDate(connection.updatedAt)!
                let action: String = {
                    switch status {
                    case .Sent: return receivedLast ? "Received" : "Sent"
                    case .Opened: return receivedLast ? "Received" : "Opened"
                    case .Expired: return receivedLast ? "Received" : "Opened"
                    }
                    }()
                return "\(action) \(formattedDate)"
        }
        return ""
    }
    
    func pBusy() -> ProducerProperty<Bool> {
        return ProducerProperty(combineLatest(
            VideoUploadTask.countOfUploads(self.id),
            VideoDownloadTask.countOfDownloads(self.id)
        ).map { uploads, downloads in
            uploads > 0 || downloads > 0
        })
    }
    
    func pStatus() -> ProducerProperty<String> {
        return ProducerProperty(combineLatest(
            VideoUploadTask.countOfUploads(self.id),
            VideoDownloadTask.countOfDownloads(self.id),
            CurrentTime.producer
        ).map { uploads, downloads, time in
            if uploads > 0 { return "Sending..." }
            if downloads > 0 { return "Receiving..." }
            return self.serverStatus
        })
    }
}
