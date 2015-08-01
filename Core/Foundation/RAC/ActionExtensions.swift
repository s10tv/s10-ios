//
//  ActionExtensions.swift
//  S10
//
//  Created by Tony Xiao on 8/1/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa

// Counter part to ReactiveCocoa's <~ operator which is sometimes inconvenient to use

infix operator ~> {
    associativity left
    precedence 93
}

// MARK: - Actions
// Technically doesn't belong in this file, but let's see if it compiles

extension UIControl {
    public func addAction<I, O, E: ErrorType>(action: Action<I, O, E>, forControlEvents events: UIControlEvents = .TouchUpInside) {
        addTarget(action.unsafeCocoaAction, action: CocoaAction.selector, forControlEvents: events)
    }
}

public func ~> <I, O, E: ErrorType>(control: UIControl, action: Action<I, O, E>) {
    control.addAction(action)
}
