//
//  SignalExtensions.swift
//  S10
//
//  Created by Tony Xiao on 8/3/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

// A value that's impossible to construct
public enum NoValue {}

public func ignoreValues<T, E>(signal: Signal<T, E>) -> Signal<NoValue, E> {
    return signal.filter { _ in false }.map { $0 as! NoValue }
}
