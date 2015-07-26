//
//  ProfileInfoViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public protocol ProfileInfoViewModel {
}

public struct TaylrProfileInfoViewModel : ProfileInfoViewModel{
    public let jobTitle: PropertyOf<String>
    public let employer: PropertyOf<String>
    public let about: PropertyOf<String>
    
    init(user: User) {
        jobTitle = user.pJobTitle()
        employer = user.pEmployer()
        about = user.pAbout()
    }
}

public struct ConnectedProfileInfoViewModel : ProfileInfoViewModel {
    public struct Attribute {
        public let label: String
        public let value: String
    }
    
    public let avatar: Image
    public let displayName: String
    public let displayId: String
    public let authenticated: Bool
    public let attributes: [Attribute]
    
    init(profile: User.ConnectedProfile) {
        avatar = profile.avatar
        displayName = profile.displayName
        displayId = profile.displayId ?? ""
        authenticated = profile.authenticated ?? false
        attributes = profile.attributes.map {
            Attribute(label: $0.label, value: $0.value)
        }
    }
}