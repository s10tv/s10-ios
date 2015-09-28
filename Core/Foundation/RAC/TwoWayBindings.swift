//
//  TwoWayBindings.swift
//  S10
//
//  Created by Tony Xiao on 9/28/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

infix operator <<~> {
    associativity right

    // Binds tighter than assignment but looser than everything else
    precedence 93
}

public func <<~> <Destination: MutablePropertyType, Source: MutablePropertyType where Source.Value == Destination.Value>(destinationProperty: Destination, sourceProperty: Source) -> Disposable {
    let cd = CompositeDisposable()
    var updating = false
    cd += sourceProperty.producer.startWithNext { v in
        if !updating {
            updating = true
            destinationProperty.value = v
            updating = false
        }
    }
    cd += destinationProperty.producer.skip(1).startWithNext { v in
        if !updating {
            updating = true
            sourceProperty.value = v
            updating = false
        }
    }
    return cd
}
