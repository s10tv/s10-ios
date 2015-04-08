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

let π = CGFloat(M_PI)

func LS(localizableKey: String, args: CVarArgType...) -> String {
    return NSString(format: NSLocalizedString(localizableKey, comment: ""),
                 arguments: getVaList(args)) as String
}

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
    
    // TODO: Figure out when to tear down the subscriptions for gesture recognizers
    func whenTapped(block: () -> ()) {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.rac_gestureSignal().subscribeNextAs { (recognizer : UIGestureRecognizer) -> () in
            if recognizer.state == .Ended {
                block()
            }
        }
        addGestureRecognizer(tap)
    }

    func whenSwiped(direction: UISwipeGestureRecognizerDirection, block: () -> ()) {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = direction
        swipe.rac_gestureSignal().subscribeNextAs { (recognizer : UIGestureRecognizer) -> () in
            if recognizer.state == .Ended {
                block()
            }
        }
        addGestureRecognizer(swipe)
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

// TODO: Remove UIAlertView all together. It's deprecated
extension UIAlertView {
    class func show(title: String, message: String? = nil) -> RACSignal {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        return alert.rac_buttonClickedSignal()
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