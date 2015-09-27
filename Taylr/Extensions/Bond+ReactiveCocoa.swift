//
//  Bond+ReactiveCocoa.swift
//  S10
//
//  Created by Tony Xiao on 9/26/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

// MARK: - ReactiveCocoa + SwiftBonds

private class BridgeDisposable : Bond.DisposableType {
    let disposable: ReactiveCocoa.Disposable
    var isDisposed: Bool { return disposable.disposed }
    
    init(_ disposable: ReactiveCocoa.Disposable) {
        self.disposable = disposable
    }
    func dispose() {
        disposable.dispose()
    }
}

extension Disposable {
    private func bnd() -> Bond.DisposableType {
        return BridgeDisposable(self)
    }
}

public extension PropertyType {
    public func bindTo<B: BindableType where B.Element == Value>(bindable: B) -> DisposableType {
        let disposable = SerialDisposable(otherDisposable: nil)
        let sink = bindable.sink(disposable)
        disposable.otherDisposable = producer.startWithNext(sink).bnd()
        return disposable
    }
}

public extension MutablePropertyType {
    public func bidirectionalBindTo<B: BindableType where B: EventProducerType, B.EventType == Value, B.Element == Value>(bindable: B) -> DisposableType {
        let d1 = bindTo(bindable)
        let d2 = bindable.observeNew { [weak self] value in
            self?.value = value
        }
        return Bond.CompositeDisposable([d1, d2])
    }
}

public func ->> <O: PropertyType, B: BindableType where B.Element == O.Value>(source: O, destination: B) -> DisposableType {
    return source.bindTo(destination)
}

public func ->>< <O: MutablePropertyType, B: BindableType where B: EventProducerType, B.EventType == O.Value, B.Element == O.Value>(source: O, destination: B) -> DisposableType {
    return source.bidirectionalBindTo(destination)
}

// MARK: - ReactiveCocoa only binding

public func ->> <P: PropertyType, T where P.Value == T>(source: P, sink: Event<T, NoError>.Sink) -> Disposable {
    return source.producer.start(sink)
}
