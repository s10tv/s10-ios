//
//  GradientBackgroundView.swift
//  Ketch
//
//  Created by Tony Xiao on 3/6/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

@IBDesignable class GradientBackgroundView : BaseView {
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let topCenter = CGPointMake(CGRectGetMidX(bounds), 0)
        let bottomCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds))
        CGContextDrawLinearGradient(context, StyleKit.gradientWater2, topCenter, bottomCenter, 0)
    }
}
