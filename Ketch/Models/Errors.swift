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
//    case KetchyUnavailable = -2
    
    var nsError: NSError { return NSError(self) }
    var recoverable: Bool { return localizedRecoverySuggestion != nil }
    
    var localizedDescription: String {
        switch self {
        case .NetworkUnreachable: return LS(.errNetworkUnreachable)
        case .BetaProdBothInstalled: return LS(.errBetaProdBothInstalledTitle)
        }
    }
    var localizedRecoverySuggestion: String? {
        switch self {
        case .NetworkUnreachable: return LS(.errNetworkUnreachableRecovery)
        case .BetaProdBothInstalled: return LS(.errBetaProdBothInstalledMessage)
        }
    }
}

extension NSError {
    convenience init(_ errorCode: ErrorCode) {
        self.init(domain: "Ketch", code: errorCode.rawValue, userInfo: [
            NSLocalizedDescriptionKey: errorCode.localizedDescription,
            NSLocalizedRecoverySuggestionErrorKey: errorCode.localizedRecoverySuggestion ?? NSNull()
        ].filter { k, v in v != NSNull() })
    }
    
    var recoverable: Bool {
        return ErrorCode(rawValue: code)!.recoverable
    }
}

extension UIViewController {
    func showErrorAlert(error: NSError) {
        showAlert(error.localizedDescription, message: error.localizedRecoverySuggestion)
    }
}