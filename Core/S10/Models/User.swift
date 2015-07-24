//
//  User.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import Meteor
import Bond
import ReactiveCocoa
import ObjectMapper

extension _User {
    func dyn(keyPath: UserKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
}

public struct STUser {
    
    let _user: _User
    public let firstName: DynamicOptionalTypedProperty<String>
    public let lastName: DynamicOptionalTypedProperty<String>
    public let jobTitle: DynamicOptionalTypedProperty<String>
    public let profiles: PropertyOf<[Profile]>? = nil
    
    public init(user: _User) {
        _user = user
        firstName = user.dyn(.firstName).optional(String)
        lastName = user.dyn(.lastName).optional(String)
        jobTitle = user.dyn(.jobTitle).optional(String)
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

@objc(User)
public class User: _User {
    
    public private(set) lazy var dynEmployer: PropertyOf<String?> = {
        return self.dyn(UserKeys.employer.rawValue).optional(String) |> readonly
    }()
    
    public private(set) lazy var dynJobTitle: PropertyOf<String?> = {
        return self.dyn(UserKeys.jobTitle.rawValue).optional(String) |> readonly
    }()

    public private(set) lazy var dynFirstName: Dynamic<String?> = {
        return self.dynValue(UserKeys.firstName)
    }()
    
    public private(set) lazy var dynLastName: Dynamic<String?> = {
        return self.dynValue(UserKeys.lastName)
    }()
    
    public private(set) lazy var dynUsername: Dynamic<String?> = {
        return self.dynValue(UserKeys.username)
    }()
    
    public private(set) lazy var dynDistance: Dynamic<Double?> = {
        return self.dynValue(UserKeys.distance)
    }()
    
    public private(set) lazy var dynLastActive: Dynamic<NSDate?> = {
        return self.dynValue(UserKeys.lastActive)
    }()
    
    public private(set) lazy var dynAbout: Dynamic<String?> = {
        return self.dynValue(UserKeys.about)
    }()
    
    public private(set) lazy var dynAvatar: Dynamic<Image?> = {
        return self.dynValue(UserKeys.avatar).map(Mapper<Image>().map)
    }()
    
    public private(set) lazy var dynCover: Dynamic<Image?> = {
        return self.dynValue(UserKeys.cover).map(Mapper<Image>().map)
    }()

    public private(set) lazy var displayName: Dynamic<String> = {
        return reduce(self.dynFirstName, self.dynLastName) {
            return String(format: "%@ %@", $0 ?? "", $1 ?? "").nonBlank() ?? ""
        }
    }()
    
    public private(set) lazy var dynConnection: Dynamic<Connection?> = {
        return self.dynValue(UserKeys.connection)
    }()
    
    public class func findByDocumentID(context: NSManagedObjectContext, documentID: String) -> User? {
        return context.objectInCollection("users", documentID: documentID) as? User
    }
}
