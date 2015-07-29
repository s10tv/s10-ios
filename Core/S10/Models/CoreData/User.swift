//
//  User.swift
//  S10
//
//  Created on 1/20/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import ObjectMapper
import EDColor

internal class ColorTransform: TransformType {
    typealias Object = UIColor
    typealias JSON = String
    
    init() {}
    
    func transformFromJSON(value: AnyObject?) -> UIColor? {
        if let colorHex = value as? String {
            return UIColor(hexString: colorHex)
        }
        return nil
    }
    
    func transformToJSON(value: UIColor?) -> String? {
        // BUGBUG?
        return nil
    }
}


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
    
    struct ConnectedProfile : Mappable {
        var id: String!
        var icon: Image!
        var avatar: Image!
        var displayName: String!
        var displayId: String?
        var authenticated: Bool?
        var url: NSURL!
        var integrationName: String!
        var themeColor: UIColor!
        var attributes: [Attribute]!
        
        init?(_ map: Map) {
            mapping(map)
        }
        
        mutating func mapping(map: Map) {
            id <- map["id"]
            icon <- map["icon"]
            avatar <- map["avatar"]
            displayName <- map["displayName"]
            displayId <- map["displayId"]
            authenticated <- map["authenticated"]
            integrationName <- map["integrationName"]
            themeColor <- (map["themeColor"], ColorTransform())
            url <- (map["url"], URLTransform())
            attributes <- map["attributes"]
        }
        
        struct Attribute : Mappable {
            var label: String!
            var value: String!
            
            init?(_ map: Map) {
                mapping(map)
            }
            
            mutating func mapping(map: Map) {
                label <- map["label"]
                value <- map["value"]
            }
        }
    }
}

