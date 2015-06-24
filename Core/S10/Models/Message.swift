//
//  Message.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import ReactiveCocoa
import Bond
import Core

@objc(Message)
public class Message: _Message {
    
    public enum Status : String {
        case Sending = "sending"
        case Sent = "sent"
        case Delivered = "delivered"
        case Opened = "opened"
        case Expired = "expired"
    }
    
    public private(set) lazy var dynStatus: Dynamic<Status?> = {
        return self.dynValue(MessageAttributes.status.rawValue).map { $0.map { Status(rawValue: $0) } ?? nil }
    }()
    
    public private(set) lazy var dynCreatedAt: Dynamic<NSDate?> = {
        return self.dynValue(MessageAttributes.createdAt.rawValue)
    }()
    
    public private(set) lazy var dynExpiresAt: Dynamic<NSDate?> = {
        return self.dynValue(MessageAttributes.expiresAt.rawValue)
    }()

    public var statusEnum: Status {
        get { return status.map { Status(rawValue: $0) ?? .Sending } ?? .Sending }
        set(newValue) { status = newValue.rawValue }
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        statusEnum = .Sending
        createdAt = NSDate()
    }
}

