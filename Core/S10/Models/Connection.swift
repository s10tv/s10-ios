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

@objc(Connection)
public class Connection: _Connection {
    
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
        let messages = Message.by(NSPredicate(format: "%K != %@ && %K == %@",
            MessageKeys.status.rawValue, "sending",
            MessageKeys.connection.rawValue, self))
        let sortDesc = NSSortDescriptor(key: MessageKeys.createdAt.rawValue, ascending: true)
        return sorted ? messages.sorted(by: sortDesc).frc() : messages.frc()
    }
    
    public class func findByDocumentID(context: NSManagedObjectContext, documentID: String) -> Connection? {
        return context.objectInCollection("connections", documentID: documentID) as? Connection
    }
    
}
