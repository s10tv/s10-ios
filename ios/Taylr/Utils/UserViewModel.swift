//
//  Context.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

struct Context {
    let layer: LayerService
    
    var currentUserId: String? {
        return nil
    }
}

class UserViewModel : NSObject {
    let userId: String
    var avatarURL: NSURL? = nil
    var coverURL: NSURL? = nil
    var firstName: String = ""
    var lastName: String = ""
    var displayName: String = ""
    
    init(userId: String) {
        self.userId = userId
    }
}