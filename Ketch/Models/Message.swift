//
//  Message.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Message)
class Message: _Message {
    var outgoing: Bool { return sender!.isCurrentUser }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
}

