//
//  CandidateBubble.swift
//  Ketch
//
//  Created by Tony Xiao on 3/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

// TODO: Seems like candidateBubble is better implemented as a 
// subclass of UIControl rather than UIView. 
class CandidateBubble : BaseView {
    
    let avatar = UserAvatarView()
    let scaleDuration : NSTimeInterval = 0.2

    // For use by GameVC
    var dynamicCenter : CGPoint?
    var drag : UIAttachmentBehavior?
    var candidate: Candidate? {
        didSet { avatar.user = candidate?.user }
    }
    
    override func commonInit() {
        userInteractionEnabled = true
        addSubview(avatar)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = nil
    }
    
    // NOTE: It's better to manually layout the avatar view inside candidate bubble
    // Relying on autolayout to layout avatar view and having candidate bubble be manipulated
    // by UIDyanmicsAnimator causes layout to be repeatedly invalidated, potentially bad performance
    override func layoutSubviews() {
        avatar.center = bounds.center
        avatar.bounds.size = bounds.size
        super.layoutSubviews()
    }
    
    // MARK: - Scaling avatar size as bubble size increases
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        UIView.animateWithDuration(scaleDuration) {
            self.layer.zPosition = 1
            self.avatar.transform = CGAffineTransform(scale: 1.5)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        UIView.animate(scaleDuration, delay: 0.1) {
            self.layer.zPosition = 0
            self.avatar.transform = CGAffineTransformIdentity
        }
    }
    
    override func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        // Ensure that touchesEnded will be called to properly scale avatar size back
        gestureRecognizer.cancelsTouchesInView = false
        super.addGestureRecognizer(gestureRecognizer)
    }
    
    // Wiggling
    
    private func randomPathForWigging() -> CGPathRef {
        let boundingBox = bounds.scaleFromCenter(0.3)
        let path = UIBezierPath()
        path.moveToPoint(boundingBox.center)
        let step = UInt32(boundingBox.width + boundingBox.height) / 10
        var count = 0
        while count < 100 {
            let newPoint = path.currentPoint + CGPoint(
                x: CGFloat(arc4random_uniform(step)) - CGFloat(step) / 2,
                y: CGFloat(arc4random_uniform(step)) - CGFloat(step) / 2
            )
            if boundingBox.contains(newPoint) {
                path.addLineToPoint(newPoint)
                count++
            }
        }
        return path.CGPath
    }
    
    func setWigglingEnabled(enabled: Bool) {
        let kWiggle = "position"
        if enabled {
            let wiggle = CAKeyframeAnimation(keyPath: kWiggle)
            wiggle.path = randomPathForWigging()
            wiggle.duration = 100
            wiggle.autoreverses = true
            wiggle.repeatCount = Float.infinity
            avatar.layer.addAnimation(wiggle, forKey: kWiggle)
        } else {
            avatar.layer.removeAnimationForKey(kWiggle)
        }
    }
    
}
