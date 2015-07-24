//
//  UserViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper

extension _User {
    func dyn(keyPath: UserKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
}

public struct UserViewModel {
    let _user: _User
    public let username: PropertyOf<String>
    public let firstName: PropertyOf<String>
    public let lastName: PropertyOf<String>
    public let jobTitle: PropertyOf<String>
    public let employer: PropertyOf<String>
    public let about: PropertyOf<String>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let profiles: PropertyOf<[Profile]>
    
    public let displayName: PropertyOf<String>
    
    public init(user: _User) {
        _user = user
        username = user.dyn(.username).optional(String) |> map { $0 ?? "" }
        firstName = user.dyn(.firstName).optional(String) |> map { $0 ?? "" }
        lastName = user.dyn(.lastName).optional(String) |> map { $0 ?? "" }
        jobTitle = user.dyn(.jobTitle).optional(String) |> map { $0 ?? "" }
        employer = user.dyn(.employer).optional(String) |> map { $0 ?? "" }
        about = user.dyn(.about).optional(String) |> map { $0 ?? "" }
        avatar = user.dyn(.avatar) |> map(Mapper<Image>().map)
        cover = user.dyn(.cover) |> map(Mapper<Image>().map)
        profiles = user.dyn(.connectedProfiles)
            |> map(Mapper<Profile>().mapArray)
            |> map { $0 ?? [] }
        
        displayName = PropertyOf("", combineLatest(
            self.firstName.producer,
            self.lastName.producer
        ) |> map {
            String(format: "%@ %@", $0, $1).nonBlank() ?? ""
        })
    }
    
    public struct Profile : Mappable {
        public var id: String!
        public var icon: Image!
        public var avatar: Image!
        public var displayName: String!
        public var displayId: String?
        public var authenticated: Bool?
        public var url: NSURL!
        public var attributes: [Attribute]!
        
        public init?(_ map: Map) {
            mapping(map)
        }
        
        public mutating func mapping(map: Map) {
            id <- map["id"]
            icon <- map["icon"]
            avatar <- map["avatar"]
            displayName <- map["displayName"]
            displayId <- map["displayId"]
            authenticated <- map["authenticated"]
            url <- (map["url"], URLTransform())
            attributes <- map["attributes"]
        }
        
        public struct Attribute : Mappable {
            public var label: String!
            public var value: String!
            
            public init?(_ map: Map) {
                mapping(map)
            }
            
            public mutating func mapping(map: Map) {
                label <- map["label"]
                value <- map["value"]
            }
        }
    }
}