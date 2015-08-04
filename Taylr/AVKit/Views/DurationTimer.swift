//
//  DurationTimer.swift
//  Taylr
//
//  Created by on 8/4/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import Core
import ReactiveCocoa

@IBDesignable
class DurationTimer : BaseView {
    private let progressTrack = CAShapeLayer()
    private let trackWidth: CGFloat = 2
    private var circleRadius: CGFloat = 0
    let label = UILabel()
    
    var progress: Float = 0 {
        didSet {
            assert(progress >= 0 && progress <= 1, "Progress must be between 0 and 1")
            assert(NSThread.isMainThread(), "Must run on main")
            if progressTrack.animationForKey("stroke") == nil {
                setupAnimations()
            }
            progressTrack.timeOffset = CFTimeInterval(progress)
        }
    }
    
    override func commonInit() {
        progressTrack.fillColor = UIColor.clearColor().CGColor
        progressTrack.strokeColor = UIColor.whiteColor().CGColor
        progressTrack.strokeEnd = 1
        layer.addSublayer(progressTrack)
        
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.font = UIFont(name: "GillSans", size: 14)
        label.text = "100"
        addSubview(label)
        
        setupAnimations()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleRadius = bounds.width/2 - trackWidth
        
        progressTrack.frame = bounds
        progressTrack.lineWidth = trackWidth
        progressTrack.path = UIBezierPath(arcCenter: bounds.center, radius: circleRadius,
            startAngle: 3/2*π, endAngle: -π/2, clockwise: false).CGPath
        label.frame = bounds
    }
    
    override func drawRect(rect: CGRect) {
        let circle = UIBezierPath(circleCenter: bounds.center, radius: circleRadius)
        UIColor(white: 0, alpha: 0.6).setFill()
        circle.fill()
    }
    
    func setupAnimations() {
        // Animate the progress track
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.duration = 1
        strokeAnimation.fromValue = 1
        strokeAnimation.toValue = 0
        progressTrack.addAnimation(strokeAnimation, forKey: "stroke")
        progressTrack.speed = 0 // Pause animation
    }
}