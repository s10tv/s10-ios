//
//  Message.swift
//  S10
//
//  Created on 1/20/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

@objc(Message)
internal class Message: _Message {

    enum Status : String {
        case Sent = "sent"
        case Opened = "opened"
        case Expired = "expired"
    }
    
    var status: Status {
        return Status(rawValue: status_)!
    }
    
    var video: Video {
        return Video.mapper.map(video_)!
    }
    
}
