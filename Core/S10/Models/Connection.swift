//
//  Connetion.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import CoreData
import SugarRecord
import ReactiveCocoa
import Bond

@objc(Connection)
public class Connection: _Connection {
    
    public private(set) lazy var dynLastMessageStatus: Dynamic<Message.Status?> = {
        return self.dynValue(ConnectionKeys.lastMessageStatus).map { $0.map { Message.Status(rawValue: $0) } ?? nil }
    }()
    
    public private(set) lazy var dynUpdatedAt: Dynamic<NSDate?> = {
        return self.dynValue(ConnectionKeys.updatedAt)
    }()
    
    public private(set) lazy var dynOtherUser: Dynamic<User?> = {
        return self.dynValue(ConnectionKeys.otherUser)
    }()
    
    public private(set) lazy var dynLastSender: Dynamic<User?> = {
        return self.dynValue(ConnectionKeys.lastSender)
    }()
    
    public private(set) lazy var dynUnreadCount: Dynamic<Int?> = {
        return self.dynValue(ConnectionKeys.unreadCount)
    }()
    
    // NOTE: Not meaningfully ordered for performance, despite array return type.
    public var messages: [Message] {
        return fetchMessages(sorted: false).fetchObjects() as! [Message]
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
        updatedAt = NSDate()
    }
    
    public func fetchMessages(#sorted: Bool) -> NSFetchedResultsController {
        // TODO: Filter out message without video for now to prevent crash. Should we handle in UI Layer
        let messages = Message.by(NSPredicate(format: "%K != %@ && %K == %@ && %K != nil",
            MessageKeys.status.rawValue, "sending",
            MessageKeys.connection.rawValue, self,
            MessageKeys.video.rawValue))
        let sortDesc = NSSortDescriptor(key: MessageKeys.createdAt.rawValue, ascending: true)
        return sorted ? messages.sorted(by: sortDesc).frc() : messages.frc()
    }
    
    public class func findByDocumentID(context: NSManagedObjectContext, documentID: String) -> Connection? {
        return context.objectInCollection("connections", documentID: documentID) as? Connection
    }
    
}
