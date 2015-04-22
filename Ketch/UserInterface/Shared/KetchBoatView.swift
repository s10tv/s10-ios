//
//  KetchBoatView.swift
//  Ketch
//
//  Created by Tony Xiao on 4/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class KetchBoatView : UIImageView {
    
    @IBOutlet var waveView: WaveView?

    let scaleDuration: NSTimeInterval = 0.2
    override var image: UIImage? {
        get { return super.image }
        set { super.image = newValue ?? UIImage(.ketch) }
    }
    
    func rideWaveAnimation(wavePath: UIBezierPath, duration: CFTimeInterval) -> CAAnimation {
        // Move boat along with the wave path
        let followPath = CAKeyframeAnimation(keyPath: "position")
        followPath.path = wavePath.CGPath
        followPath.rotationMode = kCAAnimationRotateAuto
        followPath.additive = true
        
        // Cancel the x component to make boat stay in place
        wavePath.applyTransform(CGAffineTransformMakeScale(-1, 0))
        let cancelPathX = CAKeyframeAnimation(keyPath: "position")
        cancelPathX.path = wavePath.CGPath
        cancelPathX.additive = true
        
        let rideWave = CAAnimationGroup()
        rideWave.duration = duration
        rideWave.repeatCount = Float.infinity
        rideWave.animations = [followPath, cancelPathX]
        return rideWave
    }
    
    func animateAlongWave() {
        if let wavePath = waveView?.wave {
            let rideWave = rideWaveAnimation(wavePath, duration: waveView!.waveDuration * Double(waveView!.periods))
            layer.addAnimation(rideWave, forKey: "rideWave")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userInteractionEnabled = true
        animateAlongWave()
    }
    
    // MARK: -
    
    // TODO: Disabling boat interactivity for now because it interferes
    // with the animation. Need to figure out better way to interact
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