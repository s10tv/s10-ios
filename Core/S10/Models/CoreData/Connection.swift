//
//  Connection.swift
//  S10
//
//  Created on 1/20/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import ObjectMapper

@objc(Connection)
internal class Connection: _Connection {
    
    var thumbnail: Image? {
        return Image.mapper.map(thumbnail_)
    }
    
    var cover: Image? {
        return Image.mapper.map(cover_)
    }
    
    var lastMessageStatus: Message.Status? {
        return lastMessageStatus_.flatMap { Message.Status(rawValue: $0) }
    }
    
}
