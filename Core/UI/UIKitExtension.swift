//
//  UIKitExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/6/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Cartography
import EDColor

extension UIView {
    public func parentViewOfType<T: UIView>(type: T.Type) -> T? {
        if let superview = superview as? T {
            return superview
        }
        return superview?.parentViewOfType(type)
    }
    
    public func fadeTransition(duration: CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.addAnimation(animation, forKey: kCATransitionFade)
    }
}

extension UIViewController {
    public func presentViewController(viewControllerToPresent: UIViewController, animated: Bool = true) -> Future<(), NoError> {
        let promise = Promise<(), NoError>()
        presentViewController(viewControllerToPresent, animated: animated) {
            promise.success()
        }
        return promise.future
    }
    
    public func dismissViewController(animated animated: Bool = true) -> Future<(), NoError> {
        let promise = Promise<(), NoError>()
        dismissViewControllerAnimated(animated) {
            promise.success()
        }
        return promise.future
    }
    
    public func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction("Ok", style: .Cancel)
        presentViewController(alert)
    }
    
    public class func topMostViewController() -> UIViewController? {
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
        }
        return topVC
    }
}

extension UIView {
    
    public func makeCircular() {
        layer.cornerRadius = max(frame.size.width, frame.size.height) / 2
        layer.masksToBounds = true
    }
    
    public func makeWidthEqualTo(view: UIView) {
        constrain(self, view) { this, that in
            this.width == that.width; return
        }
    }
    
    public func makeHeightEqualTo(view: UIView) {
        constrain(self, view) { this, that in
            this.height == that.height; return
        }
    }
    
    public func makeEdgesEqualTo(view: UIView) {
        constrain(self, view) { this, that in
            this.edges == that.edges; return
        }
    }
    
    public func whenTapEnded(block: () -> ()) {
        whenTapped { recognizer in
            if recognizer.state == .Ended { block() }
        }
    }
    
    public func whenLongPressEnded(block: () -> ()) {
        whenLongPressed { recognizer in
            if recognizer.state == .Ended { block() }
        }
    }
    
    public func whenSwipeEnded(direction: UISwipeGestureRecognizerDirection, block: () -> ()) {
        whenSwiped(direction) { recognizer in
            if recognizer.state == .Ended { block() }
        }
    }
    
    // TODO: Figure out when to tear down the subscriptions for gesture recognizers
    public func whenTapped(numberOfTaps numberOfTaps: Int = 1, block: (UITapGestureRecognizer) -> ()) {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = numberOfTaps
        tap.numberOfTouchesRequired = 1
        tap.rac_gestureSignal().subscribeNext {
            block($0 as! UITapGestureRecognizer)
        }
        addGestureRecognizer(tap)
    }
    
    public func whenLongPressed(block: (UILongPressGestureRecognizer) -> ()) {
        let tap = UILongPressGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext {
            block($0 as! UILongPressGestureRecognizer)
        }
        addGestureRecognizer(tap)
    }

    public func whenSwiped(direction: UISwipeGestureRecognizerDirection, block: (UISwipeGestureRecognizer) -> ()) {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = direction
        swipe.rac_gestureSignal().subscribeNext {
            block($0 as! UISwipeGestureRecognizer)
        }
        addGestureRecognizer(swipe)
    }
    
    public func whenPanned(handler: (UIPanGestureRecognizer) -> ()) {
        let pan = UIPanGestureRecognizer()
        pan.rac_gestureSignal().subscribeNext {
            handler($0 as! UIPanGestureRecognizer)
        }
        addGestureRecognizer(pan)
    }
    
    public func whenEdgePanned(edge: UIRectEdge, handler: (UIScreenEdgePanGestureRecognizer, UIRectEdge) -> ()) {
        let edgePan = UIScreenEdgePanGestureRecognizer()
        edgePan.edges = edge
        edgePan.rac_gestureSignal().subscribeNext {
            handler($0 as! UIScreenEdgePanGestureRecognizer, edge)
        }
        addGestureRecognizer(edgePan)
    }
    
    public func deepCopy() -> UIView {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self)) as! UIView
    }
    
    public class func fromNib(nibName: String, owner: AnyObject? = nil) -> UIView? {
        return UINib(nibName: nibName, bundle: nil).instantiateWithOwner(owner, options: nil).first as? UIView
    }
}

extension UIAlertController {
    public func addAction(title: String, style: UIAlertActionStyle = .Default, handler: ((UIAlertAction!) -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        addAction(action)
        return action
    }
}

extension UIColor {
    public convenience init(_ hexCode: UInt32) {
        self.init(hex: hexCode)
    }
}

extension UIImage {
    
    public func scaleToMaxDimension(length: CGFloat, pixelSize: Bool = false) -> UIImage {
        let scaleFactor = length / max(size.width, size.height)
        // Don't scale up, only scale down
        if scaleFactor > 1 {
            return self
        }
        let scaledSize = CGSizeMake(size.width * scaleFactor, size.height * scaleFactor)
        return scaleToSize(scaledSize, pixelSize: pixelSize)
    }
    
    
    public func scaleToSize(newSize: CGSize, pixelSize: Bool = false) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1.0 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(newSize, false, pixelSize ? 1.0 : 0.0)
        drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public class func imageWithColor(color: UIColor, opaque: Bool = true, size: CGSize = CGSizeMake(1, 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UINavigationBar {
    public func setBackgroundColor(color: UIColor?, translucent: Bool = true) {
        let backgroundImage = color.map { UIImage.imageWithColor($0, opaque: !translucent) }
        let shadowImage = color.map { _ in UIImage() }
        self.setBackgroundImage(backgroundImage, forBarMetrics: UIBarMetrics.Default)
        self.shadowImage = shadowImage
        self.translucent = translucent
    }
}

extension UICollectionViewFlowLayout {
    public var maxItemWidth : CGFloat {
        return collectionView!.bounds.width - sectionInset.left - sectionInset.right
    }
}

public func DebugPrintAllFonts() {
    for familyName in UIFont.familyNames() {
        print("Family: \(familyName)")
        for fontName in UIFont.fontNamesForFamilyName(familyName) {
            print("\tFont: \(fontName)")
        }
    }
}