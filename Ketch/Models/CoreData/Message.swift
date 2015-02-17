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

    var videoNSURL : NSURL? {
        return videoURL != nil ? NSURL(string: videoURL!) : nil
    }

    var thumbnailNSURL : NSURL? {
        let url = thumbnailURL != nil ? NSURL(string: thumbnailURL!) : nil
        return url ?? connection?.user?.profilePhotoURL
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.timestamp = NSDate()
    }
    
    func jsqMessage() -> JSQMessage {
        let senderID = sender?.documentID
        let displayName = sender?.firstName
        let txt = text ?? "empty"
        return JSQMessage(senderId: senderID, senderDisplayName: displayName, date: timestamp, text: txt)
    }
    
}
