//
//  PulsingView.swift
//  Ketch
//
//  Created by Tony Xiao on 4/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import Cartography

class PulsingView : BaseView {
    let sublayer = CALayer()
    let imageView = UIImageView(image: UIImage(R.KetchAssets.icTapGesture))

    override func commonInit() {
        sublayer.borderWidth = 2
        sublayer.borderColor = StyleKit.white.CGColor
        sublayer.opacity = 0
        layer.addSublayer(sublayer)
        
        imageView.layer.opacity = 0
        addSubview(imageView)
        constrain(imageView, self) { imageView, this in
            imageView.width == 33
            imageView.height == 50
            imageView.left == this.centerX - 10
            imageView.top == this.centerY
        }
    }
    
    func startPulsing(delay: CFTimeInterval = 0) {
        let side = frame.width
        sublayer.frame = bounds
        sublayer.cornerRadius = side / 2
        
        let size = CABasicAnimation("bounds.size")
        size.toValue = CGSize(side: side * 2.5).value
        let corner = CABasicAnimation("cornerRadius")
        corner.toValue = sublayer.cornerRadius * 2.5
        let opacity = CABasicAnimation("opacity")
        opacity.fromValue = 1
        opacity.toValue = 0
        
        let pulsing = CAAnimationGroup()
        pulsing.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        pulsing.duration = 1
        pulsing.repeatCount = Float.infinity
        pulsing.beginTime = CACurrentMediaTime() + delay
        pulsing.animations = [size, corner, opacity]
        
        sublayer.addAnimation(pulsing, forKey: "pulsing")
        
        imageView.layer.animate(keyPath: "opacity", fillMode: .Forwards) { animation, _ in
            animation.beginTime = CACurrentMediaTime() + delay
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 1
        }
    }
    
    func stopPulsing() {
        sublayer.removeAnimationForKey("pulsing")
        imageView.layer.removeAnimationForKey("opacity")
    }
}