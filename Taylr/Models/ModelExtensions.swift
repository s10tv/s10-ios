//
//  ModelExtensions.swift
//  S10
//
//  Created by Tony Xiao on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core

extension User {
    
    var isCurrentUser : Bool {
        return documentID == Meteor.userID
    }
    
    class func currentUser() -> User? {
        return Meteor.user
    }
    
    var infoItems : [ProfileInfoItem] {
        return []
    }
}

extension Message {
    var outgoing: Bool { return sender!.isCurrentUser }
    var incoming: Bool { return !outgoing }
}

extension Connection {
    
}

extension Candidate {
    
}

extension Settings {
    var devAudience: Bool { return Globals.env.audience == .Dev }
}