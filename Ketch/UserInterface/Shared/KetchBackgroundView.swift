//
//  KetchBackgroundView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa
/*
// loading -> signup
    water bottom -> top, no boat
// loading -> game
    water bottom -> top, with boat
// game -> boat has sailed
    water top -> bottom -> boat sails -> back up with new boat has sailed view
// game -> new match
    water top -> bottom -> back up to center with bouncing avatar ball
// game <-> dock <-> chat
    water remains top, but moves laterally with boat moving out of the way
// game <-> settings
    water top -> bottom and remains bottom, presentation rather than scrolling
// game <-> profile
    avatar bubble -> expands to profile photo -> shirnks back down to avatar bubble
    water moves top -> midway point
// chat <-> profile
    top avatar -> expands to profile photo -> shrinks back down to top avatar
    water moves top -> midway point
// settings <-> profile
    avatar -> expands to profile photo -> shrinks back down to avatar
    water moves bottom -> midway point
*/
@IBDesignable class KetchBackgroundView : NibDesignableView {
    
    @IBOutlet weak var ketchIcon: UIImageView!
    @IBOutlet weak var waveView: KetchWaveView!
    @IBOutlet weak var waveTopMargin: NSLayoutConstraint!

    var animateDuration : NSTimeInterval = 0.6
    var springDamping : CGFloat = 0.6
    var initialSpringVelocity : CGFloat = 10
    
    @IBInspectable var ketchIconHidden : Bool {
        get { return ketchIcon.hidden }
        set(newValue) { ketchIcon.hidden = newValue }
    }
    
    private func animateLayoutChange() -> RACSignal {
        let subject = RACReplaySubject()
        UIView.animateWithDuration(animateDuration, delay: 0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: nil, animations: {
            self.layoutIfNeeded()
        }, completion: { finished in
            subject.sendNextAndCompleted(finished)
        })
        return subject
    }

    func animateHorizon(#ratio: CGFloat) -> RACSignal {
        assert(between(0, ratio, 1) == true, "Ratio must be between 0 and 1")
        // Question: Do we need separate constraint for ratio or convert to offset like below?
        waveTopMargin.constant = frame.height * (1 - ratio)
        return animateLayoutChange()
    }
    
    func animateHorizon(#offset: CGFloat, fromTop: Bool = true) -> RACSignal {
        waveTopMargin.constant = fromTop ? offset : frame.height - offset
        return animateLayoutChange()
    }
    
    func animateWaterlineDownAndUp(completion: ((Bool) -> ())? = nil) {
        animateHorizon(offset: 100, fromTop: false).subscribeCompleted {
            self.animateHorizon(offset: 60)
            return
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
    
}

@IBDesignable class KetchWaveView : BaseView {
    private var wavePath : UIBezierPath!
    private var wavePathInverse : UIBezierPath!
    private var phaseShift : CABasicAnimation!
    
    let waveOutline = CAShapeLayer()
    let waveMask = CAShapeLayer()
    let amplitude : CGFloat = 6
    let periods : CGFloat = 2
    let gradientHeight : CGFloat = 580
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: gradientHeight)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let topCenter = CGPointMake(CGRectGetMidX(bounds), 0)
        let bottomCenter = CGPointMake(CGRectGetMidX(bounds), gradientHeight)
        CGContextDrawLinearGradient(context, StyleKit.gradientWater2, topCenter, bottomCenter,
            CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(x: 0, y: amplitude, width: layer.bounds.width, height: layer.bounds.height)
        waveOutline.frame = frame
        waveMask.frame = frame
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
        waveOutline.removeAllAnimations()
        waveOutline.path = wavePath.CGPath
        waveOutline.lineWidth = 2.0
        waveOutline.strokeColor = UIColor(hex: 0xC5E7E6).CGColor // TODO: Use StyleKit
        waveOutline.fillColor = nil
        waveOutline.addAnimation(phaseShift, forKey: "phaseShift")
        layer.addSublayer(waveOutline)
    
        // Animate the wave gradient (with mask
        waveMask.removeAllAnimations()
        waveMask.path = wavePath.CGPath
        waveMask.addAnimation(phaseShift, forKey: "phaseShift")
        layer.mask = waveMask
    }
}