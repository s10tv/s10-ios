//
//  Message.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Message)
class Message: _Message {

    var videoNSURL : NSURL? {
        return videoURL != nil ? NSURL(string: videoURL!) : nil
    }

    var thumbnailNSURL : NSURL? {
        return connection?.user?.profilePhotoURL
//        return thumbnailURL != nil ? NSURL(string: thumbnailURL!) : nil
    }
}
