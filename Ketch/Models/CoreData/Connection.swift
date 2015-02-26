//
//  Connetion.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Connection)
class Connection: _Connection {
    enum Type : String {
        case Yes = "yes"
        case Maybe = "maybe"
    }
    
    // NOTE: Not meaningfully ordered for performance, despite array return type.
    var messages: [Message] {
        return fetchMessages(sorted: false).fetchObjects() as [Message]
    }
    
    var fractionExpired : Float {
         // TODO: Make this configurable (3 days currently)
        let maxExpiration : NSTimeInterval = 3 * 24 * 60 * 60
        let timeTillExpiry = expiresAt?.timeIntervalSinceNow ?? 0
        return Float(timeTillExpiry / maxExpiration)
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
        updatedAt = NSDate()
    }
    
    func fetchMessages(#sorted: Bool) -> NSFetchedResultsController {
        let messages = Message.by(MessageRelationships.connection.rawValue, value: self)
        let sortDesc = NSSortDescriptor(key: MessageAttributes.createdAt.rawValue, ascending: true)
        return sorted ? messages.sorted(by: sortDesc).frc() : messages.frc()
    }
    
    class func findByDocumentID(documentID: String) -> Connection? {
        return Core.mainContext.objectInCollection("connections", documentID: documentID) as? Connection
    }
}
