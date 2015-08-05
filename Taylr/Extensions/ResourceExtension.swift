//
//  ResourceExtension.swift
//  Taylr
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
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

extension UITableView {
    func dequeueReusableCellWithIdentifier(identifier: TableViewCellreuseIdentifier) -> UITableViewCell? {
        return dequeueReusableCellWithIdentifier(identifier.rawValue) as? UITableViewCell
    }
    
    @availability(iOS, introduced=6.0)
    func dequeueReusableCellWithIdentifier(identifier: TableViewCellreuseIdentifier, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(identifier.rawValue, forIndexPath: indexPath) as! UITableViewCell
    }
}

extension UITableViewCell {
    static func reuseId(id: TableViewCellreuseIdentifier) -> String {
        return id.rawValue
    }
}

extension UICollectionView {
    func dequeueReusableCellWithReuseIdentifier(identifier: CollectionViewCellreuseIdentifier, forIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell {
        return dequeueReusableCellWithReuseIdentifier(identifier.rawValue, forIndexPath: indexPath) as! UICollectionViewCell
    }
}

extension UICollectionViewCell {
    static func reuseId(id: CollectionViewCellreuseIdentifier) -> String {
        return id.rawValue
    }
}

// xcres

func LS(key: R.Strings, args: CVarArgType...) -> String {
    return NSString(format: NSLocalizedString(key.rawValue, comment: ""),
        arguments: getVaList(args)) as String
}

extension UIImage {
    convenience init?(_ key: R.TaylrAssets) {
        self.init(named: key.rawValue)
    }
}

extension UIFont {
    convenience init!(_ fontName: R.Fonts, size: CGFloat) {
        self.init(name: fontName.rawValue, size: size)
    }
}