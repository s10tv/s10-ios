//
//  AlertableError.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public protocol AlertableError : ErrorType {
    var alert: ErrorAlert { get }
}

public struct ErrorAlert : AlertableError {
    let underlyingError: ErrorType?
    public let title: String?
    public let message: String?
    public let style: UIAlertControllerStyle
    public let actions: [UIAlertAction]
    
    public var domain: String { return nsError.domain }
    public var code: Int { return nsError.code }
    
    public init(title: String, message: String? = nil, style: UIAlertControllerStyle = .Alert, actions: [UIAlertAction]? = nil, underlyingError: ErrorType? = nil) {
        self.title = title
        self.message = message
        self.style = style
        self.actions = actions ?? [UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)]
        self.underlyingError = underlyingError
    }
    
    public func matches(domain: String, code: Int? = nil) -> Bool {
        let e = nsError
        return domain == e.domain && (code.map { $0 == e.code } ?? true)
    }
    
    // MARK: - AlertableError
    
    public var nsError: NSError {
        return underlyingError?.nsError ??
            NSError(domain: "Alert", code: 0, userInfo: [
                NSLocalizedDescriptionKey: title ?? "",
                NSLocalizedFailureReasonErrorKey: message ?? ""
                ])
    }
    
    public var alert: ErrorAlert { return self }
}

// MARK: - Client & Server error extensions

extension ErrorAlert {
    public func matches(error: ClientError) -> Bool {
        if let e = underlyingError as? ClientError {
            return e == error
        }
        return false
    }
    
    public func matches(error: ServerError) -> Bool {
        if let e = underlyingError as? ServerError {
            return e == error
        }
        return false
    }
}

public func ==(lhs: AlertableError, rhs: ClientError) -> Bool {
    if let lhs = lhs as? ClientError {
        return lhs == rhs
    }
    return lhs.alert.matches(rhs)
}

public func ==(lhs: AlertableError, rhs: ServerError) -> Bool {
    if let lhs = lhs as? ServerError {
        return lhs == rhs
    }
    return lhs.alert.matches(rhs)
}