//
//  Errors.swift
//  Taylr
//
//  Created by Tony Xiao on 4/21/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit

enum ErrorCode : Int {
    case NetworkUnreachable = -1
    case SubscriptionError = -3
    
    static let nsErrorDomain = "S10"
    var nsError: NSError { return NSError(self) }
    var recoverable: Bool { return localizedRecoverySuggestion != nil }
    
    var localizedDescription: String {
        switch self {
        case .NetworkUnreachable: return LS(.errNetworkUnreachable)
        default: return LS(.errDefault)
        }
    }
    var localizedRecoverySuggestion: String? {
        switch self {
        case .NetworkUnreachable: return LS(.errNetworkUnreachableRecovery)
        default: return LS(.errDefaultRecovery)
        }
    }
}

extension NSError {
    convenience init(_ errorCode: ErrorCode) {
        self.init(domain: ErrorCode.nsErrorDomain, code: errorCode.rawValue, userInfo: [
            NSLocalizedDescriptionKey: errorCode.localizedDescription,
            NSLocalizedRecoverySuggestionErrorKey: errorCode.localizedRecoverySuggestion ?? NSNull()
        ].filter { k, v in v != NSNull() })
    }
    
    var recoverable: Bool {
        return ErrorCode(rawValue: code)!.recoverable
    }
    
    func match(errorCode: ErrorCode) -> Bool {
        return domain == ErrorCode.nsErrorDomain && code == errorCode.rawValue
    }
}

extension UIViewController {
    func showErrorAlert(error: NSError) {
        showAlert(error.localizedDescription, message: error.localizedRecoverySuggestion)
    }
}