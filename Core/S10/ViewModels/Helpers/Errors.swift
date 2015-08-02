//
//  Alert.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa

public enum ClientError : String, AlertableError {
    case Validation = "validation"
    case Offline = "offline"
    
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

/*
{
    error: {
        code: 55
        code '1232'
        alert: {
            title: ""
            message: ""
        }
    }
}
*/