//
//  User.swift
//  S10
//
//  Created on 1/20/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import ObjectMapper

@objc(User)
internal class User: _User {

    var avatar: Image? {
        return Image.mapper.map(avatar_)
    }
    
    var cover: Image? {
        return Image.mapper.map(cover_)
    }
    
    var connectedProfiles: [ConnectedProfile] {
        return connectedProfiles_.flatMap(Mapper<ConnectedProfile>().mapArray) ?? []
    }
}

public struct ConnectedProfile : Mappable {
    public var id: String!
    public var icon: Image!
    public var avatar: Image!
    public var displayName: String!
    public var displayId: String?
    public var authenticated: Bool?
    public var url: NSURL!
    public var integrationName: String!
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
        integrationName <- map["integrationName"]
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

