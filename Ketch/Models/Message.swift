//
//  Message.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import JSQMessagesViewController

@objc(Message)
class Message: _Message {
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
    func jsqMessage() -> JSQMessage {
        let senderID = sender?.documentID
        let displayName = sender?.firstName
        let txt = text ?? "empty"
        return JSQMessage(senderId: senderID, senderDisplayName: displayName, date: createdAt, text: txt)
    }
    
}
