//
//  ProgressIndicator.swift
//  Taylr
//
//  Created by Tony Xiao on 3/13/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation

@IBDesignable class ProgressIndicator : UIImageView {
    @IBInspectable var currentPage : Int = 1 {
        didSet {
            image = UIImage(named: "game-progressIndicator-\(currentPage)")
            let transition = CATransition()
            transition.duration = 0.75
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            layer.addAnimation(transition, forKey: nil)
        }
    }
}