//
//  GameView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol CandidateDropZone {
    var isOccupied: Bool { get }
    var dropCenter: CGPoint { get }
    func dropBubble(bubble: CandidateBubble)
    func freeBubble()
}

class GameView : TransparentView, UIDynamicAnimatorDelegate {
    @IBOutlet var buckets: [ChoiceBucket]!
    @IBOutlet var boxes: [FloatBox]!
    @IBOutlet weak var helpText: DesignableLabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var bubbles: [CandidateBubble] = []
    var velocityFactor : CGFloat = 0.1 // Multiplied with pan velocity to compute new pos
    var animator : UIDynamicAnimator!
    var collision : UICollisionBehavior!
    var isReady : Bool {
        return buckets.reduce(true) { $0 && $1.bubble != nil }
    }
    var didConfirmChoices : (() -> ())?
    
    override func commonInit() {
        super.commonInit()
        userInteractionEnabled = true
        passThroughTouchOnSelf = false
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        for i in 0...2 {
            let bubble = CandidateBubble()
            bubble.userInteractionEnabled = true
            bubble.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "_handleBubblePan:"))
            addSubview(bubble)
            bubbles.append(bubble)
        }
//        whenTapped {
//            self.dropBubbles()
//        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for box in boxes { box.animator = animator }
        for (i, bucket) in enumerate(buckets) {
            bucket.animator = animator
            bucket.choice = [Candidate.Choice.Yes, Candidate.Choice.Maybe, Candidate.Choice.No][i] // TODO: Less hack...
        }
        for (i, bubble) in enumerate(bubbles) {
            bubble.frame = self.boxes[i].frame
            bubble.makeCircular()
        }
        
        collision = UICollisionBehavior(items: bubbles)
        collision.collisionMode = UICollisionBehaviorMode.Items
    }
    
    @IBAction func confirmChoices(sender: AnyObject) {
        if let block = didConfirmChoices { block() }
    }
    
    // MARK: - Public API
    
    func chosenCandidate(choice: Candidate.Choice?) -> Candidate? {
        return buckets.filter({ $0.choice == choice }).first?.bubble?.candidate
    }
    
    func dropBubbles() {
        animator.removeBehavior(collision)
        for (i, bubble) in enumerate(bubbles) {
            bubble.dropzone = nil
            bubble.center = CGPoint(x: boxes[i].center.x, y: -200)
        }
        let gravity = UIGravityBehavior(items: bubbles)
        gravity.magnitude = 5
        gravity.action = {
            if abs(self.bubbles[0].center.y - self.frame.height) < 20 {
                for (i, bubble) in enumerate(self.bubbles) {
                    bubble.dropzone = self.boxes[i]
                }
                self.animator.addBehavior(self.collision)
                self.animator.removeBehavior(gravity)
            }
        }
        animator.addBehavior(gravity)
    }
    
    func startNewGame(candidates: [Candidate]) {
        assert(candidates.count == 3 && bubbles.count == 3, "Must have exactly 3 candidates & bubbles to start game")
        helpText.hidden = true
        confirmButton.hidden = true
        for (i, bubble) in enumerate(bubbles) {
            bubble.candidate = candidates[i]
        }
        dropBubbles()
    }
    
    // MARK: - Drag and flick handling
    
    private func closestFreeTarget(point: CGPoint) -> CandidateDropZone {
        var dropzones: [CandidateDropZone] = []
        for box in boxes { dropzones.append(box as CandidateDropZone) }
        for bucket in buckets { dropzones.append(bucket as CandidateDropZone) }
        dropzones = dropzones.filter { !$0.isOccupied }
        return dropzones.minElement { Float($0.dropCenter.distanceTo(point)) }!
    }
    
    func _handleBubblePan(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(self)
        let bubble = pan.view as CandidateBubble
        switch pan.state {
        case .Began:
            bubble.dropzone = nil
            animator.removeBehavior(bubble.drag)
            bubble.drag = UIAttachmentBehavior(item: bubble, attachedToAnchor: location)
            animator.addBehavior(bubble.drag)
        case .Changed:
            bubble.drag?.anchorPoint = location
        case .Ended:
            for b in bubbles { animator.removeBehavior(b.drag) }
            let expectedLocation = bubble.center + pan.velocityInView(self) * velocityFactor
            bubble.dropzone = closestFreeTarget(expectedLocation)
            confirmButton.hidden = !isReady
        default:
            break
        }
    }

}
