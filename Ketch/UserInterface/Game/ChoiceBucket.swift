//
//  ChoiceBucket.swift
//  Ketch
//
//  Created by Tony Xiao on 3/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class ChoiceBucket : UIImageView, CandidateDropZone {
    var animator : UIDynamicAnimator!
    var snap : UISnapBehavior?
    var choice : Candidate.Choice?
    weak var bubble : CandidateBubble?
    var dropCenter : CGPoint {
        return center + CGPoint(x: 0, y: -11)
    }
    
    var isOccupied : Bool { return bubble != nil }
    
    func dropBubble(bubble: CandidateBubble) {
        self.bubble = bubble
        snap = UISnapBehavior(item: bubble, snapToPoint: dropCenter)
        animator.addBehavior(snap)
    }
    
    func freeBubble() {
        bubble = nil
        animator.removeBehavior(snap)
    }
}