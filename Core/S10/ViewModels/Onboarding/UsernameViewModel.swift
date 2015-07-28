//
//  UsernameViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa


public struct UsernameViewModel {
    public enum Error : ErrorType {
        case NoInternet
        case NoUsernameSelected
        case UsernameIsTaken
        
        public var alertTitle: String { return "" }
        public var alertBody: String { return "" }
        public var nsError: NSError { return NSError() }
    }
    
    public let usernamePlaceholder: String
    public let username: MutableProperty<String>
    public let statusImage: PropertyOf<Image?>
    public let showSpinner: PropertyOf<Bool>
    public let statusMessage: PropertyOf<String>
    public let statusColor: PropertyOf<UIColor>

    public func saveUsername() -> Future<Void, Error> {
        let promise = Promise<(), Error>()
        return promise.future
    }
}