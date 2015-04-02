//
//  WaveView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

@IBDesignable class WaveView : BaseView {
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
        
        wavePathInverse = UIBezierPath.sineWave(amplitude: amplitude,
            wavelength: CGRectGetWidth(layer.frame)/2,
            periods: periods, phase: π)
        
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
        waveOutline.strokeColor = StyleKit.waterlineStrokeColor.CGColor
        waveOutline.fillColor = nil
        waveOutline.addAnimation(phaseShift, forKey: "phaseShift")
        layer.addSublayer(waveOutline)
        
        // Animate the wave gradient (with mask)
        let waveMaskPath = wavePath.copy() as UIBezierPath
        let waveMaskInversePath = wavePathInverse.copy() as UIBezierPath
        
        for path in [waveMaskPath, waveMaskInversePath] {
            path.addLineTo(x: frame.width+1, y: 0)
            path.addLineTo(x: frame.width+1, y: frame.height+1)
            path.addLineTo(x: -1, y: frame.height+1)
            path.addLineTo(x: -1, y: -1)
            path.closePath()
        }
        
        let waveMaskPhaseShift = phaseShift.copy() as CABasicAnimation
        waveMaskPhaseShift.fromValue = waveMaskPath.CGPath
        waveMaskPhaseShift.toValue = waveMaskInversePath.CGPath
        
        waveMask.removeAllAnimations()
        waveMask.path = waveMaskPath.CGPath
        waveMask.addAnimation(waveMaskPhaseShift, forKey: "waveMaskPhaseShift")
        layer.mask = waveMask
    }
}