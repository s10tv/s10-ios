//
//  ResourceExtension.swift
//  Ketch
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//
//  Extensions to make accessing generated resources easier

import UIKit

// SBConstants

extension UIStoryboard {
    func makeViewController(identifier: ViewControllerStoryboardIdentifier) -> UIViewController {
        return instantiateViewControllerWithIdentifier(identifier.rawValue) as! UIViewController
    }
    func makeInitialViewController() -> UIViewController {
        return instantiateInitialViewController() as! UIViewController
    }
}

extension UIViewController {
    func makeViewController(identifier: ViewControllerStoryboardIdentifier) -> UIViewController? {
        return storyboard?.makeViewController(identifier)
    }
    
    func performSegue(identifier: SegueIdentifier, sender: AnyObject? = nil) {
        performSegueWithIdentifier(identifier.rawValue, sender: sender)
    }
}

extension UIStoryboardSegue {
    func matches(identifier: SegueIdentifier) -> Bool {
        return self.identifier == identifier.rawValue
    }
}

// xcres

func LS(key: R.Strings, args: CVarArgType...) -> String {
    return NSString(format: NSLocalizedString(key.rawValue, comment: ""),
        arguments: getVaList(args)) as String
}

extension UIImage {
    convenience init?(_ key: R.KetchAssets) {
        self.init(named: key.rawValue)
    }
}

extension UIFont {
    convenience init!(_ fontName: R.Fonts, size: CGFloat) {
        self.init(name: fontName.rawValue, size: size)
    }
}