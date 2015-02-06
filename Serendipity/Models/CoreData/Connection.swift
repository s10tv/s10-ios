//
//  Connetion.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Connection)
class Connection: _Connection {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.dateCreated = NSDate()
        self.dateUpdated = NSDate()
    }

}
