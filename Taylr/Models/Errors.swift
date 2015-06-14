//
//  Errors.swift
//  Ketch
//
//  Created by Tony Xiao on 4/21/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

enum ErrorCode : Int {
    case NetworkUnreachable = -1
    case BetaProdBothInstalled = -2
    case SubscriptionError = -3
//    case KetchyUnavailable = -2
    
    static let nsErrorDomain = "Ketch"
    var nsError: NSError { return NSError(self) }
    var recoverable: Bool { return localizedRecoverySuggestion != nil }
    
    var localizedDescription: String {
        switch self {
        case .NetworkUnreachable: return LS(.errNetworkUnreachable)
        case .BetaProdBothInstalled: return LS(.errBetaProdBothInstalledTitle)
        default: return LS(.errDefault)
        }
    }
    var localizedRecoverySuggestion: String? {
        switch self {
        case .NetworkUnreachable: return LS(.errNetworkUnreachableRecovery)
        case .BetaProdBothInstalled: return LS(.errBetaProdBothInstalledMessage)
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