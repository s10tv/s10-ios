//
//  SettingsBackgroundView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/27/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

@IBDesignable class SettingsBackgroundView : BaseView {
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let topCenter = CGPointMake(CGRectGetMidX(bounds), 0)
        let bottomCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds))
        CGContextDrawLinearGradient(context, StyleKit.gradientSand, topCenter, bottomCenter, 0)
    }
}