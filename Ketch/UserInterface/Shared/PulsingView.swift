//
//  PulsingView.swift
//  Ketch
//
//  Created by Tony Xiao on 4/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class PulsingView : BaseView {
    
    func startPulsing(delay: CFTimeInterval = 0) {
        let side = frame.width
        layer.cornerRadius = side / 2
        layer.borderWidth = 2
        layer.borderColor = StyleKit.white.CGColor
        layer.opacity = 0
        
        let size = CABasicAnimation("bounds.size")
        size.toValue = CGSize(side: side * 2.5).value
        let corner = CABasicAnimation("cornerRadius")
        corner.toValue = layer.cornerRadius * 2.5
        let opacity = CABasicAnimation("opacity")
        opacity.fromValue = 1
        opacity.toValue = 0
        
        let pulsing = CAAnimationGroup()
        pulsing.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        pulsing.duration = 2
        pulsing.repeatCount = Float.infinity
        pulsing.beginTime = CACurrentMediaTime() + delay
        pulsing.animations = [size, corner, opacity]
        
        layer.addAnimation(pulsing, forKey: "pulsing")
    }
    
    func stopPulsing() {
        layer.removeAnimationForKey("pulsing")
    }
}