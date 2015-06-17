//
//  Animation.swift
//  Taylr
//
//  Created by Tony Xiao on 4/6/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Core

extension UIView {
    public func setHiddenAnimated(#hidden: Bool, duration: NSTimeInterval = 0.3, delay: NSTimeInterval = 0) -> RACSignal {
        // TODO: This is obviously repetitive, but let's wait to RAC 3.0 is out to clean this up
        let subject = RACSubject()
        UIView.animateWithDuration(duration, delay: delay, options: nil, animations: {
            if hidden {
                self.alpha = 0
            } else {
                self.hidden = false
                self.alpha = 1
            }
        }) { finished in
            if hidden && finished {
                self.hidden = true
            }
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
}

// Class Extensions
extension UIView {
    
//    public class func animateSpring(duration: NSTimeInterval, animations: () -> ()) -> RACSignal {
//        return UIView.animateSpring(duration, delay: 0, animations: animations)
//    }
    
    public class func animateSpring(duration: NSTimeInterval, damping: CGFloat = 0.7, velocity: CGFloat = 0.7,
                        options: UIViewAnimationOptions = nil, delay: NSTimeInterval = 0, animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        UIView.animateWithDuration(duration, delay: delay,
            usingSpringWithDamping: damping, initialSpringVelocity: velocity,
            options: options, animations:animations) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
    
//    public class func animate(duration: NSTimeInterval, animations: () -> ()) -> RACSignal {
//        return UIView.animate(duration, delay: 0, animations: animations)
//    }
    
    public class func animate(duration: NSTimeInterval, options: UIViewAnimationOptions = nil, delay: NSTimeInterval = 0, animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
}

// MARK: - CALayer Extensions

extension CALayer {
    
    public func animateKeyPath(keyPath: String, toValue: AnyObject!, duration: CGFloat, fillMode: CAMediaTimingFillMode = .Removed) -> RACSignal {
        let animation = CABasicAnimation(keyPath, fillMode: fillMode)
        animation.toValue = toValue
        return animation.addToLayerAndReturnSignal(self, forKey: keyPath)
    }
    
    public func animateOpacity(opacity: CGFloat, duration: CGFloat, fillMode: CAMediaTimingFillMode = .Removed) -> RACSignal {
        return animateKeyPath("opacity", toValue: opacity, duration: duration, fillMode: fillMode)
    }
    
    public func animate(#keyPath: String, fillMode: CAMediaTimingFillMode = .Removed, configure: (CABasicAnimation, CALayer) -> ()) -> RACSignal {
        let animation = CABasicAnimation(keyPath, fillMode: fillMode)
        configure(animation, self)
        return animation.addToLayerAndReturnSignal(self, forKey: keyPath)
    }
}

// MARK: - Animation block callback

extension CAAnimation {
    private class ProxyDelegate : NSObject {
        let subject = RACSubject()
        
        override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
            subject.sendNextAndCompleted(flag)
        }
    }

    // CAAnimation is an exception and actually retains its delegate, thus no need to use objc_associated_object
    // BUG NOTE: Trying to merge stopSignals is problematic. Next values are not being delivered
    public var stopSignal : RACSignal {
        if !(delegate is ProxyDelegate) {
            delegate = ProxyDelegate()
        }
        return (delegate as! ProxyDelegate).subject
    }
    
    // CAAnimation has value semantic, must save signal prior to adding to layer
    public func addToLayerAndReturnSignal(layer: CALayer, forKey: String) -> RACSignal {
        let signal = stopSignal
        layer.addAnimation(self, forKey: forKey)
        return signal
    }
}

extension CATransaction {
    public class func perform(animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        CATransaction.begin()
        animations()
        CATransaction.setCompletionBlock {
            subject.sendCompleted()
        }
        CATransaction.commit()
        return subject
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

