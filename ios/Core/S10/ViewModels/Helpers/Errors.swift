//
//  Alert.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa

public let eOffline = ErrorAlert(title: "No Network Connection", message: "Your internet connection appears to be offline right now. Please try again later.")

public enum ClientError : String, AlertableError {
    case Validation = "validation"
    case Offline = "offline"
    case InvalidInvite = "Invalid Invite"
    case InvalidServerResponse = "Invalid Server Response"
    
    public var nsError: NSError {
        return NSError(domain: "Client", code: 0, userInfo: [
            "code": rawValue
        ])
    }
    
    public var alert: ErrorAlert {
        return ErrorAlert(title: rawValue, underlyingError: self)
    }
}

public enum ServerError : String, AlertableError {
    case Validation = "validation"
    
    public var nsError: NSError {
        return NSError(domain: "Client", code: 0, userInfo: [
            "code": rawValue
        ])
    }
    public var alert: ErrorAlert {
        return ErrorAlert(title: rawValue, underlyingError: self)
    }
}
