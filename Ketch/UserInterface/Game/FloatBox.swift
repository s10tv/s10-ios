//
//  FloatTarget.swift
//  Ketch
//
//  Created by Tony Xiao on 3/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

// TODO: Add math library for this
func DegreesToRadians (value:Int) -> CGFloat {
    return CGFloat(value) * π / 180.0
}

class FloatBox : TransparentView {
    let brownianMagnitude : CGFloat = 0.075
    let brownianInterval : NSTimeInterval = 1.5
    var animator : UIDynamicAnimator!
    var snap : UISnapBehavior!
    var boundingBox : UICollisionBehavior!
    var brownianPush : UIPushBehavior!
    var floatEnabled = true

    weak var bubble : CandidateBubble?
    
    override func commonInit() {
        super.commonInit()
        // TODO: Find better way to implement this
        RACSignal.interval(brownianInterval,
            onScheduler: RACScheduler.mainThreadScheduler()).subscribeNext { [weak self] _ in
            if let this = self {
                if this.floatEnabled { this.kickIfNeeded() }
            }
        }
    }
    
    private func boundIfCloseEnough() {
        if self.bubble?.center.distanceTo(self.dropCenter) < 10 {
            let margin = CGRectGetWidth(frame) / 2 * 1.15 // 15% larger than size of placeholder
            let top = dropCenter.y - margin
            let bottom = dropCenter.y + margin
            let left = dropCenter.x - margin
            let right = dropCenter.x + margin
            
            boundingBox = UICollisionBehavior(items: [bubble!])
            boundingBox.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x: left, y: top), toPoint: CGPoint(x: right, y: top))
            boundingBox.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x: left, y: bottom), toPoint: CGPoint(x: right, y: bottom))
            boundingBox.addBoundaryWithIdentifier("left", fromPoint: CGPoint(x: left, y: top), toPoint: CGPoint(x: left, y: bottom))
            boundingBox.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x: right, y: top), toPoint: CGPoint(x: right, y: bottom))
            animator.addBehavior(boundingBox)
            animator.removeBehavior(snap)
        }
    }
    
    private func kickIfNeeded() {
        if let item = bubble {
            animator.removeBehavior(brownianPush)
            brownianPush = UIPushBehavior(items: [item], mode: .Instantaneous)
            brownianPush.magnitude = brownianMagnitude
            brownianPush.angle = DegreesToRadians(Int(arc4random()) % 360)
            animator.addBehavior(brownianPush)
        }
    }
}

extension FloatBox : CandidateDropZone {
    var dropCenter : CGPoint { return center }
    var isOccupied : Bool { return bubble != nil }
    
    func dropBubble(bubble: CandidateBubble) {
        self.bubble = bubble
        snap = UISnapBehavior(item: bubble, snapToPoint: dropCenter)
        snap.action = { [weak self] in
            if let this = self {
                this.boundIfCloseEnough()
            }
        }
        animator.addBehavior(snap)
    }
    
    func freeBubble() {
        animator.removeBehavior(snap)
        animator.removeBehavior(boundingBox)
        animator.removeBehavior(brownianPush)
        self.bubble = nil
    }
}
