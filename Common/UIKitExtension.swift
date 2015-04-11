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
    func presentViewController(viewControllerToPresent: UIViewController, animated: Bool = true) -> RACSignal {
        let subject = RACReplaySubject()
        presentViewController(viewControllerToPresent, animated: animated) {
            subject.sendCompleted()
        }
        return subject
    }
    
    func dismissViewController(animated: Bool = true) -> RACSignal {
        let subject = RACReplaySubject()
        dismissViewControllerAnimated(animated) {
            subject.sendCompleted()
        }
        return subject
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction("Ok", style: .Cancel)
        presentViewController(alert)
    }
}

extension UIView {
    
    func makeCircular() {
        layer.cornerRadius = max(frame.size.width, frame.size.height) / 2
        layer.masksToBounds = true
    }
    
    func makeWidthEqualTo(view: UIView) {
        constrain(self, view) { this, that in
            this.width == that.width; return
        }
    }
    
    func makeHeightEqualTo(view: UIView) {
        constrain(self, view) { this, that in
            this.height == that.height; return
        }
    }
    
    func makeEdgesEqualTo(view: UIView) {
        constrain(self, view) { this, that in
            this.edges == that.edges; return
        }
    }
    
    func whenTapEnded(block: () -> ()) {
        whenTapped { recognizer in
            if recognizer.state == .Ended { block() }
        }
    }
    
    func whenSwipeEnded(direction: UISwipeGestureRecognizerDirection, block: () -> ()) {
        whenSwiped(direction) { recognizer in
            if recognizer.state == .Ended { block() }
        }
    }
    
    // TODO: Figure out when to tear down the subscriptions for gesture recognizers
    func whenTapped(block: (UITapGestureRecognizer) -> ()) {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.rac_gestureSignal().subscribeNextAs { (recognizer : UITapGestureRecognizer) -> () in
            block(recognizer)
        }
        addGestureRecognizer(tap)
    }

    func whenSwiped(direction: UISwipeGestureRecognizerDirection, block: (UISwipeGestureRecognizer) -> ()) {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = direction
        swipe.rac_gestureSignal().subscribeNextAs { (recognizer : UISwipeGestureRecognizer) -> () in
            block(recognizer)
        }
        addGestureRecognizer(swipe)
    }
    
    func whenPanned(handler: (UIPanGestureRecognizer) -> ()) {
        let pan = UIPanGestureRecognizer()
        pan.rac_gestureSignal().subscribeNextAs { (recognizer : UIPanGestureRecognizer) -> () in
            handler(recognizer)
        }
        addGestureRecognizer(pan)
    }
    
    func whenEdgePanned(edge: UIRectEdge, handler: (UIScreenEdgePanGestureRecognizer, UIRectEdge) -> ()) {
        let edgePan = UIScreenEdgePanGestureRecognizer()
        edgePan.edges = edge
        edgePan.rac_gestureSignal().subscribeNextAs { (recognizer : UIScreenEdgePanGestureRecognizer) -> () in
            handler(recognizer, edge)
        }
        addGestureRecognizer(edgePan)
    }
    
    class func fromNib(nibName: String, owner: AnyObject? = nil) -> UIView? {
        return UINib(nibName: nibName, bundle: nil).instantiateWithOwner(owner, options: nil).first as? UIView
    }
}

extension UIAlertController {
    func addAction(title: String, style: UIAlertActionStyle = .Default, handler: ((UIAlertAction!) -> Void)? = nil) {
        addAction(UIAlertAction(title: title, style: style, handler: handler))
    }
}

extension UIColor {
    convenience init(_ hexCode: UInt32) {
        self.init(hex: hexCode)
    }
}

extension UICollectionViewFlowLayout {
    var maxItemWidth : CGFloat {
        return collectionView!.bounds.width - sectionInset.left - sectionInset.right
    }
}

func DebugPrintAllFonts() {
    for familyName in UIFont.familyNames() as [String] {
        println("Family: \(familyName)")
        for fontName in UIFont.fontNamesForFamilyName(familyName) {
            println("\tFont: \(fontName)")
        }
    }
}