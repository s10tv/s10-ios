//
//  OnboardingError.swift
//  S10
//
//  Created by Qiming Fang on 7/31/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class Error : ErrorType {

    public var nsError: NSError { return NSError() }

    public let title: String
    public let body: String

    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}