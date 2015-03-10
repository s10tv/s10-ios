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
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Setup boat pitching animation
        let pitch = CABasicAnimation(keyPath: "transform.rotation")
        pitch.fromValue = 0.2
        pitch.toValue = -0.2
        pitch.autoreverses = true
        pitch.duration = 3
        pitch.repeatCount = Float.infinity
        ketchIcon.layer.addAnimation(pitch, forKey: "pitching")
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let topCenter = CGPointMake(CGRectGetMidX(bounds), 0)
        let bottomCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds))
        CGContextDrawLinearGradient(context, StyleKit.gradientWater2, topCenter, bottomCenter, 0)
    }
}