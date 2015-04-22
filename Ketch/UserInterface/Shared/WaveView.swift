//
//  WaveView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

@IBDesignable class WaveView : BaseView {
    private let outlineLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    let gradientHeight: CGFloat = 580
    let waveDuration: CFTimeInterval = 6
    let waveAmplitude: CGFloat = 4.5
    private(set) var waveLength: CGFloat!
    private(set) var periods: CGFloat!
    private(set) var wave: UIBezierPath!
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: gradientHeight)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let topCenter = CGPointMake(CGRectGetMidX(bounds), 0)
        let bottomCenter = CGPointMake(CGRectGetMidX(bounds), gradientHeight)
        CGContextDrawLinearGradient(context, StyleKit.gradientWater, topCenter, bottomCenter,
            CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation))
    }
    
    override func commonInit() {
        layer.addSublayer(outlineLayer)
        layer.mask = maskLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let sublayerFrame = CGRect(origin: CGPoint(x: 0, y: waveAmplitude), size: bounds.size)
        outlineLayer.frame = sublayerFrame
        maskLayer.frame = sublayerFrame
        waveLength = bounds.width / 2
        periods = (UIScreen.mainScreen().bounds.width + waveLength) / waveLength
        wave = UIBezierPath.sineWave(amplitude: waveAmplitude, wavelength: waveLength, periods: periods)
        animate()
    }
    
    // MARK: -
    
    func animate() {
        let phaseShift = CABasicAnimation(keyPath: "position.x")
        phaseShift.byValue = -1 * waveLength
        phaseShift.duration = waveDuration
        phaseShift.repeatCount = Float.infinity
        
        // Animate the wave outline
        outlineLayer.removeAllAnimations()
        outlineLayer.path = wave.CGPath
        outlineLayer.lineWidth = 2.0
        outlineLayer.strokeColor = StyleKit.navyLight.CGColor
        outlineLayer.fillColor = nil
        outlineLayer.addAnimation(phaseShift, forKey: "position.x")
        layer.addSublayer(outlineLayer)
        
        // Animate the wave mask
        let maskPath = wave.copy() as UIBezierPath
        maskPath.addLineTo(distance: waveLength, bearing: 90)
        maskPath.addLineTo(distance: frame.height+1, bearing: 180)
        maskPath.addLineTo(distance: waveLength * (periods+1), bearing: 270)
        maskPath.addLineTo(distance: frame.height+1, bearing: 0)
        maskPath.closePath()
        
        // Animate the wave gradient (with mask)
        maskLayer.path = maskPath.CGPath
        maskLayer.addAnimation(phaseShift, forKey: "position.x")
    }
}