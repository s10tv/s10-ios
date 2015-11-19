//
//  ResourceExtension.swift
//  Taylr
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//
//  Extensions to make accessing generated resources easier

import UIKit

func LS(key: R.Strings, _ args: CVarArgType...) -> String {
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