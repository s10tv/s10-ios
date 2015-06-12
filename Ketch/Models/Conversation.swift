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

@objc(Conversation)
class Conversation: _Conversation {
    
    // NOTE: Not meaningfully ordered for performance, despite array return type.
    var messages: [Message] {
        return fetchMessages(sorted: false).fetchObjects() as! [Message]
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
        updatedAt = NSDate()
    }
    
    func fetchMessages(#sorted: Bool) -> NSFetchedResultsController {
        let messages = Message.by(MessageRelationships.conversation.rawValue, value: self)
        let sortDesc = NSSortDescriptor(key: MessageAttributes.createdAt.rawValue, ascending: true)
        return sorted ? messages.sorted(by: sortDesc).frc() : messages.frc()
    }
    
    class func findByDocumentID(documentID: String) -> Conversation? {
        return Meteor.mainContext.objectInCollection("conversations", documentID: documentID) as? Conversation
    }
    
}
