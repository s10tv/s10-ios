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
