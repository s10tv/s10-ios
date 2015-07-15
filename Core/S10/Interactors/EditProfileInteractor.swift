//
//  EditProfileInteractor.swift
//  S10
//
//  Created by Tony Xiao on 7/14/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class EditProfileInteractor {
    public let firstName: PropertyOf<String>
    public let lastName: PropertyOf<String>
    public let about: PropertyOf<String>
    public let username: PropertyOf<String>
    public let avatarImageURL: PropertyOf<NSURL?>
    public let coverImageURL: PropertyOf<NSURL?>
    
    let meteor: MeteorService
    let user: User
    
    public init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        firstName = user.dyn("firstName").optional(String) |> map { $0 ?? "" }
        lastName = user.dyn("lastName").optional(String) |> map { $0 ?? "" }
        about = user.dyn("about").optional(String) |> map { $0 ?? "" }
        username = user.dyn("username").optional(String) |> map { $0 ?? "" }
        avatarImageURL = user.dyn("avatarUrl").optional(String) |> map { NSURL.fromString($0) }
        coverImageURL = user.dyn("coverUrl").optional(String) |> map { NSURL.fromString($0) }
    }
}
