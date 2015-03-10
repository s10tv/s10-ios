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
    @IBOutlet weak var waveTopMargin: NSLayoutConstraint!

    var waterlineUpperBound : CGFloat = 60 // TODO: Get this value for nib rather than hard code
    var waterlineLowerBound : CGFloat {
        return CGRectGetHeight(self.frame) - 100
    }
    var animateDuration: NSTimeInterval = 0.4
    @IBInspectable var showNavButtons : Bool = true {
        didSet {
            updateNavButtonsVisibility()
        }
    }
    
    private func updateNavButtonsVisibility() {
        settingsButton.hidden = !showNavButtons
        ketchIcon.hidden = !showNavButtons
        dockButton.hidden = !showNavButtons
    }
    
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
        waveTopMargin.constant = waterlineLowerBound
        animateLayoutChange(completion: completion)
    }
    
    func animateWaterlineUp(completion: ((Bool) -> ())? = nil) {
        waveTopMargin.constant = waterlineUpperBound
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
        
        updateNavButtonsVisibility()
        // Setup boat pitching animation
        let pitch = CABasicAnimation(keyPath: "transform.rotation")
        pitch.fromValue = 0.2
        pitch.toValue = -0.2
        pitch.autoreverses = true
        pitch.duration = 3
        pitch.repeatCount = Float.infinity
        ketchIcon.layer.addAnimation(pitch, forKey: "pitching")
    }
    
}

@IBDesignable class KetchWaveView : BaseView {
    private var wavePath : UIBezierPath!
    private var wavePathInverse : UIBezierPath!
    private var phaseShift : CABasicAnimation!
    
    let waveOutline = CAShapeLayer()
    let waveMask = CAShapeLayer()
    let amplitude : CGFloat = 6
    let periods : CGFloat = 2
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let topCenter = CGPointMake(CGRectGetMidX(bounds), 0)
        let bottomCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds))
        CGContextDrawLinearGradient(context, StyleKit.gradientWater2, topCenter, bottomCenter, 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(x: 0, y: amplitude, width: layer.bounds.width, height: layer.bounds.height)
        waveOutline.frame = frame
        waveMask.frame = frame
        if wavePath == nil {
            // Generate the paths & Animation
            wavePath = UIBezierPath.sineWave(amplitude: amplitude,
                wavelength: CGRectGetWidth(layer.frame)/2,
                periods: periods, phase: 0)
            wavePath.addLineToPoint(CGPoint(x: frame.width, y: frame.height))
            wavePath.addLineToPoint(CGPoint(x: 0, y: frame.height))
            wavePath.closePath()
            
            wavePathInverse = UIBezierPath.sineWave(amplitude: amplitude,
                wavelength: CGRectGetWidth(layer.frame)/2,
                periods: periods, phase: π)
            wavePathInverse.addLineToPoint(CGPoint(x: frame.width, y: frame.height))
            wavePathInverse.addLineToPoint(CGPoint(x: 0, y: frame.height))
            wavePathInverse.closePath()
            
            phaseShift = CABasicAnimation(keyPath: "path")
            phaseShift.fromValue = wavePath.CGPath
            phaseShift.toValue = wavePathInverse.CGPath
            phaseShift.duration = 3
            phaseShift.autoreverses = true
            phaseShift.repeatCount = Float.infinity
            
            // Animate the wave outline
            waveOutline.path = wavePath.CGPath
            waveOutline.lineWidth = 2.0
            waveOutline.strokeColor = UIColor(hex: 0xC5E7E6).CGColor // TODO: Use StyleKit
            waveOutline.fillColor = nil
            waveOutline.addAnimation(phaseShift, forKey: "phaseShift")
            layer.addSublayer(waveOutline)
            
            // Animate the wave gradient (with mask
            waveMask.path = wavePath.CGPath
            waveMask.addAnimation(phaseShift, forKey: "phaseShift")
            layer.mask = waveMask
        }
    }
}