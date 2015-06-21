//
//  Message.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Message)
public class Message: _Message {
    
    public enum Status : String {
        case Sending = "sending"
        case Sent = "sent"
        case Delivered = "delivered"
        case Opened = "opened"
        case Expired = "expired"
    }
    
    public var statusEnum: Status {
        get { return status.map { Status(rawValue: $0) ?? .Sending } ?? .Sending }
        set(newValue) { status = statusEnum.rawValue }
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        statusEnum = .Sending
        createdAt = NSDate()
    }
}

