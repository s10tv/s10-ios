//
//  MatchTimer.swift
//  S10
//
//  Created by Tony Xiao on 9/12/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Core
import ReactiveCocoa

@IBDesignable
class MatchTimer : BaseView {
    private let progressTrack = CAShapeLayer()
    private let trackWidth: CGFloat = 2
    private var circleRadius: CGFloat = 0
    let label = UILabel()
    
    var progress: Float = 0 {
        didSet {
            let progress = max(min(self.progress, 1), 0)
            assert(NSThread.isMainThread(), "Must run on main")
            if progressTrack.animationForKey("stroke") == nil {
                setupAnimations()
            }
            progressTrack.timeOffset = CFTimeInterval(progress)
        }
    }
    
    override func commonInit() {
        progressTrack.fillColor = UIColor.clearColor().CGColor
        progressTrack.strokeColor = UIColor.blackColor().CGColor
        progressTrack.strokeEnd = 0.75
        layer.addSublayer(progressTrack)
        
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.font = UIFont(.cabinRegular, size: 16)
        label.text = "22:45"
        addSubview(label)
        setTranslatesAutoresizingMaskIntoConstraints(false)
        
//        setupAnimations()
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
        circle.lineWidth = 3
        UIColor(hex: 0xC3C3C3).setStroke() // Gray
        circle.stroke()
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
