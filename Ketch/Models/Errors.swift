//
//  Errors.swift
//  Ketch
//
//  Created by Tony Xiao on 4/21/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

enum ErrorCode : Int {
    case NetworkUnreachable = 1
    
    var nsError: NSError {
        return NSError(self)
    }
    
    var recoverable: Bool {
        switch self {
        case .NetworkUnreachable: return true
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .NetworkUnreachable: return LS(.networkUnreachable)
        }
    }
}

extension NSError {
    convenience init(_ errorCode: ErrorCode) {
        self.init(domain: "Ketch", code: errorCode.rawValue, userInfo: [
            NSLocalizedDescriptionKey: errorCode.localizedDescription
        ])
    }
    
    var recoverable: Bool {
        return ErrorCode(rawValue: code)!.recoverable
    }
}