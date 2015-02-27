//
//  SettingsBackgroundView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/27/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

@IBDesignable class SettingsBackgroundView : BaseView {
    let gradient = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = layer.bounds
    }
    
    override func commonInit() {
        gradient.colors = [
            UIColor(hex: 0xE1DEC9).CGColor,
            UIColor(hex: 0xF0FAF7).CGColor,
        ]
        layer.insertSublayer(gradient, atIndex: 0)
    }
}