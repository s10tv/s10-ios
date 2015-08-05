//
//  RecordButton.swift
//  Taylr
//
//  Created on 8/4/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import Core

@IBDesignable
class RecordButton : BaseView {
    
    private let progressTrack = CAShapeLayer()
    private let outerBorderWidth: CGFloat = 3
    private var innerCircleRadius: CGFloat = 0
    private var trackWidth: CGFloat = 0
    private var trackRadius: CGFloat = 0
    private var outerRadius: CGFloat = 0
    
    var progress: Float = 0 {
        didSet {
            let progress = max(min(self.progress, 1), 0)
            assert(NSThread.isMainThread(), "Must run on main")
            if progressTrack.animationForKey("stroke") == nil
                || layer.animationForKey("scale") == nil {
                setupAnimations()
            }
            progressTrack.timeOffset = CFTimeInterval(progress)
            layer.timeOffset = CFTimeInterval(progress)
        }
    }
    
    override func commonInit() {
        progressTrack.fillColor = UIColor.clearColor().CGColor
        progressTrack.strokeColor = StyleKit.brandPurple.colorWithAlpha(0.6).CGColor
        progressTrack.strokeEnd = 0
        layer.addSublayer(progressTrack)
        
        setupAnimations()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = bounds.width/2
        outerRadius = radius - outerBorderWidth / 2
        trackWidth = (radius - outerBorderWidth) * 0.4
        innerCircleRadius = (radius - outerBorderWidth) * 0.6
        trackRadius = innerCircleRadius + trackWidth / 2
        
        progressTrack.frame = bounds
        progressTrack.lineWidth = trackWidth
        progressTrack.path = UIBezierPath(arcCenter: bounds.center, radius: trackRadius,
            startAngle: -π/2, endAngle: 3/2*π, clockwise: true).CGPath
    }
    
    override func drawRect(rect: CGRect) {
        let outerBorderPath = UIBezierPath(circleCenter: bounds.center, radius: outerRadius)
        outerBorderPath.lineWidth = outerBorderWidth
        UIColor.whiteColor().setStroke()
        outerBorderPath.stroke()
        
        let innerCircle = UIBezierPath(circleCenter: bounds.center, radius: innerCircleRadius)
        UIColor(white: 1, alpha: 0.6).setFill()
        innerCircle.fill()
    }
    
    func setupAnimations() {
        // Animate the progress track
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.duration = 1
        strokeAnimation.fromValue = 0 // no circle
        strokeAnimation.toValue = 1 // full circle
        progressTrack.addAnimation(strokeAnimation, forKey: "stroke")
        progressTrack.speed = 0 // Pause animation
        
        // Make the button 40% larger as we go
        let expectedAnimationDuration: CGFloat = 15
        let original = NSValue(CATransform3D: CATransform3DIdentity)
        let scaled = NSValue(CATransform3D: CATransform3DMakeScale(1.4, 1.4, 1))
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.duration = 1
        scaleAnimation.values = [original, scaled, scaled]
        scaleAnimation.keyTimes = [0, 1/expectedAnimationDuration, 1]
        layer.addAnimation(scaleAnimation, forKey: "scale")
        layer.speed = 0
    }
}