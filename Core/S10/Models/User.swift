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

@objc(User)
public class User: _User {
    
    public enum Gender : String {
        case Male = "male"
        case Female = "female"
    }
    
    public private(set) lazy var dynFirstName: Dynamic<String?> = {
        return self.dynValue(UserKeys.firstName)
    }()
    
    public private(set) lazy var dynLastName: Dynamic<String?> = {
        return self.dynValue(UserKeys.lastName)
    }()
    
    public private(set) lazy var avatarURL: Dynamic<NSURL?> = {
        return self.dynValue(UserKeys.avatarUrl).map { NSURL.fromString($0) }
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
