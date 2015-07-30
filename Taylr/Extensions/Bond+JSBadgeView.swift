//
//  Bond+JSBadgeView.swift
//  S10
//
//  Created by Tony Xiao on 7/29/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import JSBadgeView

var badgeTextDynamicHandleJSBadgeView: UInt8 = 0

extension JSBadgeView : Bondable {
    public var designatedBond: Bond<String> { return dynBadgeText.valueBond }
    
    public var dynBadgeText: Dynamic<String> {
        if let d: AnyObject = objc_getAssociatedObject(self, &badgeTextDynamicHandleJSBadgeView) {
            return (d as? Dynamic<String>)!
        } else {
            let d = InternalDynamic<String>(self.badgeText ?? "")
            let bond = Bond<String>() { [weak self] v in if let s = self { s.badgeText = v } }
            d.bindTo(bond, fire: false, strongly: false)
            d.retain(bond)
            objc_setAssociatedObject(self, &badgeTextDynamicHandleJSBadgeView, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return d
        }
    }
}