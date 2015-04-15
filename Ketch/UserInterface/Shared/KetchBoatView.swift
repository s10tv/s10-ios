//
//  KetchBoatView.swift
//  Ketch
//
//  Created by Tony Xiao on 4/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class KetchBoatView : UIImageView {

    let scaleDuration: NSTimeInterval = 0.2
    override var image: UIImage? {
        get { return super.image }
        set { super.image = newValue ?? UIImage(R.KetchAssets.ketch) }
    }
    
    func animatePitch() {
        layer.animate(keyPath: "transform.rotation") { pitch, _ in
            pitch.fromValue = 0.2
            pitch.toValue = -0.2
            pitch.autoreverses = true
            pitch.duration = 3
            pitch.repeatCount = Float.infinity
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animatePitch()
    }
    
    // MARK: -
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        UIView.animate(scaleDuration) {
            self.transform = CGAffineTransform(scale: 1.5)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        UIView.animate(scaleDuration, delay: 0.1) {
            self.transform = CGAffineTransformIdentity
        }
    }
}