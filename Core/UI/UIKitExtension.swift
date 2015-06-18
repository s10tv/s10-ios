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

extension UIViewController {
    public func presentViewController(viewControllerToPresent: UIViewController, animated: Bool = true) -> RACSignal {
        let subject = RACReplaySubject()
        presentViewController(viewControllerToPresent, animated: animated) {
            subject.sendCompleted()
        }
        return subject
    }
    
    public func dismissViewController(animated: Bool = true) -> RACSignal {
        let subject = RACReplaySubject()
        dismissViewControllerAnimated(animated) {
            subject.sendCompleted()
        }
        return subject
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
    public func whenTapped(numberOfTaps: Int = 1, block: (UITapGestureRecognizer) -> ()) {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = numberOfTaps
        tap.numberOfTouchesRequired = 1
        tap.rac_gestureSignal().subscribeNextAs { (recognizer : UITapGestureRecognizer) -> () in
            block(recognizer)
        }
        addGestureRecognizer(tap)
    }
    
    public func whenLongPressed(block: (UILongPressGestureRecognizer) -> ()) {
        let tap = UILongPressGestureRecognizer()
        tap.rac_gestureSignal().subscribeNextAs { (recognizer : UILongPressGestureRecognizer) -> () in
            block(recognizer)
        }
        addGestureRecognizer(tap)
    }

    public func whenSwiped(direction: UISwipeGestureRecognizerDirection, block: (UISwipeGestureRecognizer) -> ()) {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = direction
        swipe.rac_gestureSignal().subscribeNextAs { (recognizer : UISwipeGestureRecognizer) -> () in
            block(recognizer)
        }
        addGestureRecognizer(swipe)
    }
    
    public func whenPanned(handler: (UIPanGestureRecognizer) -> ()) {
        let pan = UIPanGestureRecognizer()
        pan.rac_gestureSignal().subscribeNextAs { (recognizer : UIPanGestureRecognizer) -> () in
            handler(recognizer)
        }
        addGestureRecognizer(pan)
    }
    
    public func whenEdgePanned(edge: UIRectEdge, handler: (UIScreenEdgePanGestureRecognizer, UIRectEdge) -> ()) {
        let edgePan = UIScreenEdgePanGestureRecognizer()
        edgePan.edges = edge
        edgePan.rac_gestureSignal().subscribeNextAs { (recognizer : UIScreenEdgePanGestureRecognizer) -> () in
            handler(recognizer, edge)
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

extension UICollectionViewFlowLayout {
    public var maxItemWidth : CGFloat {
        return collectionView!.bounds.width - sectionInset.left - sectionInset.right
    }
}

public func DebugPrintAllFonts() {
    for familyName in UIFont.familyNames() as! [String] {
        println("Family: \(familyName)")
        for fontName in UIFont.fontNamesForFamilyName(familyName) {
            println("\tFont: \(fontName)")
        }
    }
}