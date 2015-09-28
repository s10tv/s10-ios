//
//  DisposableExtensions.swift
//  S10
//
//  Created by Tony Xiao on 9/27/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension CompositeDisposable {
	public func addDisposable(@noescape factory: () -> Disposable?) -> DisposableHandle {
        return addDisposable(factory())
    }
}