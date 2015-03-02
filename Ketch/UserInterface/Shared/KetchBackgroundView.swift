//
//  KetchBackgroundView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

@IBDesignable class KetchBackgroundView : NibDesignableView {
    
    @IBOutlet weak var ketchIcon: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var dockButton: UIButton!
    @IBOutlet weak var skyBackground: UIView!
    @IBOutlet weak var skyHeader: UIImageView!
    
    @IBOutlet weak var skyBackgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var skyHeaderTopMargin: NSLayoutConstraint!
    
    var waterlineLowerBound: CGFloat {
        return CGRectGetHeight(self.frame) - 100
    }
    var animateDuration: NSTimeInterval = 0.4
    
    private func animateLayoutChange(completion: ((Bool) -> ())? = nil) {
        UIView.animateKeyframesWithDuration(animateDuration, delay: 0,
            options: UIViewKeyframeAnimationOptions.CalculationModeCubicPaced,
            animations: {
            self.layoutIfNeeded()
        }, { (completed) -> Void in
            if let block = completion { block(completed) }
        })
    }
    
    func animateWaterlineDown(completion: ((Bool) -> ())? = nil) {
        skyBackgroundHeight.constant = waterlineLowerBound
        skyHeaderTopMargin.constant = waterlineLowerBound
        animateLayoutChange(completion: completion)
    }
    
    func animateWaterlineUp(completion: ((Bool) -> ())? = nil) {
        skyBackgroundHeight.constant = 0
        skyHeaderTopMargin.constant = 0
        animateLayoutChange(completion: completion)
    }
    
    func animateWaterlineDownAndUp(completion: ((Bool) -> ())? = nil) {
        animateWaterlineDown { completed in
            self.animateWaterlineUp(completion: completion)
        }
    }
}