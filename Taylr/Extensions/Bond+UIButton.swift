//
//  Bond+UIButton.swift
//  S10
//
//  Created by Tony Xiao on 7/31/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Bond

private var kTitleBond: UInt8 = 0

extension UIButton  {
    var titleBond: Bond<String> {
        if let d: AnyObject = objc_getAssociatedObject(self, &kTitleBond) {
            return (d as? Bond<String>)!
        } else {
            let bond = Bond<String>() { [weak self] v in if let s = self {
                UIView.performWithoutAnimation {
                    s.setTitle(v, forState: .Normal)
                }
            } }
            objc_setAssociatedObject(self, &kTitleBond, bond, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return bond
        }
    }
}
