//
//  VolumeControl.swift
//  Taylr
//
//  Created on 8/4/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import MediaPlayer
import ReactiveCocoa
import Bond
import Core

@IBDesignable
class VolumeView : BaseView {
    
    private let hiddenVolumeView = MPVolumeView()
    private let valueTrack = CAShapeLayer()
    private let trackWidth: CGFloat = 2
    private var circleRadius: CGFloat = 0
    private let imageView = UIImageView()
    
    let vm = VolumeViewModel()
    
    override func commonInit() {
        userInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapVolumeControl"))
        
        // Add volume view but make sure we hide it
        clipsToBounds = true
        hiddenVolumeView.center = CGPoint(x: -1000, y: -1000)
        addSubview(hiddenVolumeView)
        
        // Image view in center
        imageView.contentMode = .Center
        addSubview(imageView)
        
        // Volume
        valueTrack.fillColor = UIColor.clearColor().CGColor
        valueTrack.strokeColor = UIColor(white: 1, alpha: 0.75).CGColor
        valueTrack.strokeEnd = 0
        layer.addSublayer(valueTrack)
        
        bindViewModel()
    }
    
    func bindViewModel() {
        alpha = vm.alpha
        vm.icon ->> imageView
        vm.value.producer.start(next: { [weak self] v in
            assert(NSThread.isMainThread(), "Must update on main")
            self?.valueTrack.strokeEnd = CGFloat(v)
            self?.alpha = 1
            UIView.animateSpring(0.5, delay: 1) { [weak self] in
                self?.alpha = self?.vm.alpha ?? 1
            }
        })
    }
    
    @IBAction func didTapVolumeControl() {
        vm.toggleAudioCategory()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleRadius = bounds.width/2 - trackWidth
        
        valueTrack.frame = bounds
        valueTrack.lineWidth = trackWidth
        valueTrack.path = UIBezierPath(arcCenter: bounds.center, radius: circleRadius,
            startAngle: 3/2*π, endAngle: -π/2, clockwise: false).CGPath
        
        imageView.frame = bounds
    }
    
    override func drawRect(rect: CGRect) {
        let circle = UIBezierPath(circleCenter: bounds.center, radius: circleRadius)
        UIColor(white: 0, alpha: 0.6).setFill()
        circle.fill()
    }
}