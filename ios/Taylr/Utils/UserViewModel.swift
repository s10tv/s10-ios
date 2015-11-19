//
//  Context.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import React

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

extension RCTConvert {
    @objc class func userViewModel(json: AnyObject?) -> UserViewModel? {
        if let json = json as? [String: AnyObject], let userId = json["userId"] as? String {
            let user = UserViewModel(userId: userId)
            user.firstName = json["firstName"] as? String ?? ""
            user.lastName = json["lastName"] as? String ?? ""
            user.displayName = json["displayName"] as? String ?? ""
            user.avatarURL = RCTConvert.NSURL(json["avatarUrl"])
            user.avatarURL = RCTConvert.NSURL(json["coverUrl"])
            return user
        }
        return nil
    }
}