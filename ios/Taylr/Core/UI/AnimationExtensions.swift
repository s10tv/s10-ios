//
//  Animation.swift
//  Taylr
//
//  Created by Tony Xiao on 4/6/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa

// Class Extensions
extension UIView {
    
    public class func animateSpring(duration: NSTimeInterval, damping: CGFloat = 0.7, velocity: CGFloat = 0.7,
                        options: UIViewAnimationOptions = [], delay: NSTimeInterval = 0, animations: () -> ()) -> Future<Bool, NoError> {
        let promise = Promise<Bool, NoError>()
        UIView.animateWithDuration(duration, delay: delay,
            usingSpringWithDamping: damping, initialSpringVelocity: velocity,
            options: options, animations:animations) { finished in
            promise.success(finished)
        }
        return promise.future
    }
    
    public class func animate(duration: NSTimeInterval, options: UIViewAnimationOptions = [], delay: NSTimeInterval = 0, animations: () -> ()) -> Future<Bool, NoError> {
        let promise = Promise<Bool, NoError>()
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations) { finished in
            promise.success(finished)
        }
        return promise.future
    }
}

// MARK: - CALayer Extensions

extension CALayer {
    
    public func animateKeyPath(keyPath: String, toValue: AnyObject!, duration: CGFloat, fillMode: CAMediaTimingFillMode = .Removed) -> Future<Bool, NoError> {
        let animation = CABasicAnimation(keyPath, fillMode: fillMode)
        animation.toValue = toValue
        return animation.addToLayerAndReturnFuture(self, forKey: keyPath)
    }
    
    public func animateOpacity(opacity: CGFloat, duration: CGFloat, fillMode: CAMediaTimingFillMode = .Removed) -> Future<Bool, NoError> {
        return animateKeyPath("opacity", toValue: opacity, duration: duration, fillMode: fillMode)
    }
    
    public func animate(keyPath keyPath: String, fillMode: CAMediaTimingFillMode = .Removed, configure: (CABasicAnimation, CALayer) -> ()) -> Future<Bool, NoError> {
        let animation = CABasicAnimation(keyPath, fillMode: fillMode)
        configure(animation, self)
        return animation.addToLayerAndReturnFuture(self, forKey: keyPath)
    }
}

// MARK: - Animation block callback

extension CAAnimation {
    private class ProxyDelegate : NSObject {
        let promise = Promise<Bool, NoError>()
        
        override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
            promise.success(flag)
        }
    }

    // CAAnimation is an exception and actually retains its delegate, thus no need to use objc_associated_object
    // BUG NOTE: Trying to merge stopSignals is problematic. Next values are not being delivered
    public var stopFuture : Future<Bool, NoError> {
        if !(delegate is ProxyDelegate) {
            delegate = ProxyDelegate()
        }
        return (delegate as! ProxyDelegate).promise.future
    }
    
    // CAAnimation has value semantic, must save signal prior to adding to layer
    public func addToLayerAndReturnFuture(layer: CALayer, forKey: String) -> Future<Bool, NoError> {
        let future = stopFuture
        layer.addAnimation(self, forKey: forKey)
        return future
    }
}

extension CATransaction {
    public class func perform(animations: () -> ()) -> Future<(), NoError> {
        let promise = Promise<(), NoError>()
        CATransaction.begin()
        animations()
        CATransaction.setCompletionBlock {
            promise.success()
        }
        CATransaction.commit()
        return promise.future
    }
}

// MARK: Animation Extension

public enum CAMediaTimingFillMode {
    case Forwards, Backwards, Both, Removed
    public var stringValue: String {
        switch self {
        case .Forwards:  return kCAFillModeForwards
        case .Backwards: return kCAFillModeBackwards
        case .Both:      return kCAFillModeBoth
        case .Removed:   return kCAFillModeRemoved
        }
    }
}

// Adding to CAPropertyAnimation does not result in subclass inheritance...
extension CABasicAnimation {
    public convenience init!(_ keyPath: String, duration: CFTimeInterval? = nil, fillMode: CAMediaTimingFillMode = .Removed) {
        self.init(keyPath: keyPath)
        self.fillMode = fillMode.stringValue
        if let duration = duration {
            self.duration = duration
        }
        // Forwards fill mode is meaningless if animation is removed
        if fillMode == .Forwards {
            removedOnCompletion = false
        }
    }

}

