//
//  UserViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

// Class & inherits from LayerKit because we want it to be able to conform to Participant
// Otherwise there's nothing class-like about this viewModel
public class UserViewModel: NSObject {
    public let userId: String
    public let firstName: String
    public let lastName: String
    public let displayName: String
    public let avatar: Image?
    
    init(user: User) {
        userId = user.documentID!
        firstName = user.firstName ?? ""
        lastName = user.lastName ?? ""
        displayName = user.displayName()
        avatar = user.avatar
    }
}