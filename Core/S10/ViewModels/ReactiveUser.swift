//
//  UserExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper

extension User {
    func dyn(keyPath: UserKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
    
    func pDisplayName() -> PropertyOf<String> {
        return PropertyOf("", combineLatest(
            dyn(.firstName).producer,
            dyn(.lastName).producer
        ) |> map {
            Formatters.formatFullname($0 as? String, lastName: $1 as? String)
        })
    }
    
    func pAvatar() -> PropertyOf<Image?> {
        return dyn(.avatar_) |> map(Mapper<Image>().map)
    }
    
    func pCover() -> PropertyOf<Image?> {
        return dyn(.cover_) |> map(Mapper<Image>().map)
    }
    
    func pUsername() -> PropertyOf<String> {
        return dyn(.username).optional(String) |> map { $0 ?? "" }
    }
    
    func pFirstName() -> PropertyOf<String> {
        return dyn(.firstName).optional(String) |> map { $0 ?? "" }
    }
    
    func pLastName() -> PropertyOf<String> {
        return dyn(.lastName).optional(String) |> map { $0 ?? "" }
    }
    
    func pJobTitle() -> PropertyOf<String> {
        return dyn(.jobTitle).optional(String) |> map { $0 ?? "" }
    }
    
    func pEmployer() -> PropertyOf<String> {
        return dyn(.employer).optional(String) |> map { $0 ?? "" }
    }
    
    func pAbout() -> PropertyOf<String> {
        return dyn(.about).optional(String) |> map { $0 ?? "" }
    }
}