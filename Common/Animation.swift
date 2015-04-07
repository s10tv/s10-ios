//
//  Animation.swift
//  Ketch
//
//  Created by Tony Xiao on 4/6/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UIView {
    func setHiddenAnimated(#hidden: Bool, duration: NSTimeInterval = 0.3, delay: NSTimeInterval = 0) -> RACSignal {
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
    
    class func animateSpring(duration: NSTimeInterval, animations: () -> ()) -> RACSignal {
        return UIView.animateSpring(duration, delay: 0, animations: animations)
    }
    
    class func animateSpring(duration: NSTimeInterval, damping: CGFloat = 0.7, velocity: CGFloat = 0.7,
                        options: UIViewAnimationOptions = nil, delay: NSTimeInterval = 0, animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        UIView.animateWithDuration(duration, delay: delay,
            usingSpringWithDamping: damping, initialSpringVelocity: velocity,
            options: options, animations:animations) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
    
    class func animate(duration: NSTimeInterval, animations: () -> ()) -> RACSignal {
        return UIView.animate(duration, delay: 0, animations: animations)
    }
    
    class func animate(duration: NSTimeInterval, options: UIViewAnimationOptions = nil, delay: NSTimeInterval = 0, animations: () -> ()) -> RACSignal {
        let subject = RACSubject()
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
}

// MARK: - CALayer Extensions

extension CALayer {
    
    func animateKeyPath(keyPath: String, toValue: AnyObject!, duration: CGFloat, fillForwards: Bool = false) -> RACSignal {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.toValue = toValue
        if fillForwards {
            animation.fillMode = kCAFillModeForwards
            animation.removedOnCompletion = false
        }
        return animation.addToLayerAndReturnSignal(self, forKey: keyPath)
    }
    
    func animateOpacity(opacity: CGFloat, duration: CGFloat, fillForwards: Bool = false) -> RACSignal {
        return animateKeyPath("opacity", toValue: opacity, duration: duration, fillForwards: fillForwards)
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
    var stopSignal : RACSignal {
        if !(delegate is ProxyDelegate) {
            delegate = ProxyDelegate()
        }
        return (delegate as ProxyDelegate).subject
    }
    
    // CAAnimation has value semantic, must save signal prior to adding to layer
    func addToLayerAndReturnSignal(layer: CALayer, forKey: String) -> RACSignal {
        let signal = stopSignal
        layer.addAnimation(self, forKey: forKey)
        return signal
    }
}

extension CATransaction {
    class func perform(animations: () -> ()) -> RACSignal {
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