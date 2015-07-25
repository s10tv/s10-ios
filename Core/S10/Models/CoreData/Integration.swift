//
//  Integration.swift
//  S10
//
//  Created on 1/20/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

@objc(Integration)
internal class Integration: _Integration {

    enum Status : String {
        case Linked = "linked"
        case Busy = "busy"
        case Error = "error"
        case Unlinked = "unlinked"
    }
    
    var icon: Image {
        return Image.mapper.map(icon_)!
    }
    
    var status: Status {
        return Status(rawValue: status_)!
    }
    
    var url: NSURL {
        return NSURL(url_)
    }
}
