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

class GameView : TransparentView {
    enum TutorialStep {
        case Step1, Step2, Step3
    }
    var tutorialStep: TutorialStep?
    @IBOutlet var buckets: [ChoiceBucket]!
    @IBOutlet var boxes: [FloatBox]!
    @IBOutlet weak var helpText: DesignableLabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var bubbles: [CandidateBubble] = []
    var animator : UIDynamicAnimator!
    var collision : UICollisionBehavior!
    var isReady : Bool {
        return buckets.reduce(true) { $0 && $1.bubble != nil }
    }
    var didConfirmChoices : (() -> ())?
    var velocityFactor : CGFloat = 0.1 // Multiplied with pan velocity to compute new pos
    var tutorialMode = UD[.bGameTutorialMode].bool!
    
    override func commonInit() {
        super.commonInit()
        userInteractionEnabled = true
        passThroughTouchOnSelf = false
        animator = UIDynamicAnimator(referenceView: self)
        for i in 0...2 {
            let bubble = CandidateBubble()
            bubble.userInteractionEnabled = true
            bubble.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "_handleBubblePan:"))
            addSubview(bubble)
            bubbles.append(bubble)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for box in boxes { box.animator = animator }
        for (i, bucket) in enumerate(buckets) {
            bucket.animator = animator
            bucket.choice = [Candidate.Choice.Yes, Candidate.Choice.Maybe, Candidate.Choice.No][i] // TODO: Less hack...
        }
        for bubble in bubbles {
            bubble.makeCircular()
        }

        
        collision = UICollisionBehavior(items: bubbles)
        collision.collisionMode = UICollisionBehaviorMode.Items
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (i, bubble) in enumerate(bubbles) {
            bubble.frame = self.boxes[i].frame
            bubble.makeCircular()
        }
    }
    
    @IBAction func confirmChoices(sender: AnyObject) {
        if let block = didConfirmChoices { block() }
    }
    
    // MARK: - Public API
    
    func chosenCandidate(choice: Candidate.Choice?) -> Candidate? {
        return buckets.filter({ $0.choice == choice }).first?.bubble?.candidate
    }
    
    func startNewGame(candidates: [Candidate]) {
        assert(candidates.count == 3 && bubbles.count == 3, "Must have exactly 3 candidates & bubbles to start game")
        for (i, bubble) in enumerate(bubbles) {
            bubble.candidate = candidates[i]
        }
        helpText.hidden = true
        confirmButton.hidden = true
    }
    
    // MARK: - Drag and flick handling
    private func closestTarget(point: CGPoint, filter: ((CandidateDropZone) -> Bool)? = nil) -> CandidateDropZone {
        var dropzones: [CandidateDropZone] = []
        for box in boxes { dropzones.append(box as CandidateDropZone) }
        for bucket in buckets { dropzones.append(bucket as CandidateDropZone) }
        if let f = filter {
            dropzones = dropzones.filter(f)
        }
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
            bubbles.map { self.animator.removeBehavior($0.drag) }
            let expectedLocation = bubble.center + pan.velocityInView(self) * velocityFactor
            bubble.dropzone = closestTarget(expectedLocation) { !$0.isOccupied }
            let showConfirm = isReady
            confirmButton.hidden = !showConfirm
        default:
            break
        }
    }
}
