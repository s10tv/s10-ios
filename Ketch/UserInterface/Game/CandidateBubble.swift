//
//  CandidateBubble.swift
//  Ketch
//
//  Created by Tony Xiao on 3/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

class CandidateBubble : BaseView {
    
    let avatar = UserAvatarView()
    let scaleDuration : NSTimeInterval = 0.2
    
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        UIView.animateWithDuration(scaleDuration) {
            self.layer.zPosition = 1
            self.avatar.transform = CGAffineTransform(scale: 1.5)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
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
}
