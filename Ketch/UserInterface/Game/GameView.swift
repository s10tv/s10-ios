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
    var tutorialMode = true
    
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
        whenTapped { [weak self] in
            if let step = self?.tutorialStep {
                switch (step) {
                case .Step1:
                    self?.tutorialStep2()
                    break
                case .Step2:
                    self?.tutorialStep3()
                    break
                default:
//                    self?.tutorialStep1()
                    break
                }
            }
        }
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
        for (i, bubble) in enumerate(bubbles) {
            bubble.candidate = candidates[i]
        }
        if (tutorialMode) {
            tutorialStep1()
        } else {
            helpText.hidden = true
            confirmButton.hidden = true
            dropBubbles()
        }
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
    
    private func helpTextForChoice(choice: Candidate.Choice) -> String {
        switch choice {
        case .Yes: return LS(R.Strings.marryPrompt)
        case .No: return LS(R.Strings.skipPrompt)
        case .Maybe: return LS(R.Strings.snoozePrompt)
        }
    }
    
    func _handleBubblePan(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(self)
        let bubble = pan.view as CandidateBubble
        switch pan.state {
        case .Began:
            UIView.animateWithDuration(0.25) {
                self.helpText.alpha = 0
                self.confirmButton.alpha = 0
            }
            helpText.rawText = " "
            bubble.dropzone = nil
            animator.removeBehavior(bubble.drag)
            bubble.drag = UIAttachmentBehavior(item: bubble, attachedToAnchor: location)
            animator.addBehavior(bubble.drag)
        case .Changed:
            bubble.drag?.anchorPoint = location
            if let bucket = closestTarget(bubble.center) as? ChoiceBucket {
                let text = helpTextForChoice(bucket.choice)
                if helpText.rawText != text {
                    helpText.rawText = text
                    helpText.alpha = 0
                    UIView.animateWithDuration(0.25, delay: 0.5, options: nil, animations: {
                        self.helpText.alpha = 1
                    }, completion: nil)
                }
            }
        case .Ended:
            bubbles.map { self.animator.removeBehavior($0.drag) }
            let expectedLocation = bubble.center + pan.velocityInView(self) * velocityFactor
            bubble.dropzone = closestTarget(expectedLocation) { !$0.isOccupied }
            confirmButton.hidden = !isReady
            if bubble.dropzone is FloatBox {
                UIView.animateWithDuration(0.25) {
                    self.helpText.alpha = 0
                }
            } else if let bucket = bubble.dropzone as? ChoiceBucket {
                confirmButton.alpha = 0
                let text = helpTextForChoice(bucket.choice)
                if helpText.rawText != text {
                    helpText.rawText = text
                    helpText.alpha = 0
                    UIView.animateWithDuration(0.25, animations: {
                        self.helpText.alpha = 1
                    }, completion: { _ in
                        UIView.animateWithDuration(0.25, delay: 2, options: nil, animations: {
                            self.helpText.alpha = 0
                        }, completion: { _ in
                            UIView.animateWithDuration(0.5) {
                                self.confirmButton.alpha = 1
                            }
                        })
                    })
                } else {
                    UIView.animateWithDuration(0.5) {
                        self.helpText.alpha = 0
                        self.confirmButton.alpha = 1
                    }
                }
            }
        default:
            break
        }
    }
}

// Tutorial Extension
extension GameView {
    
    // You'll see three potential matches
    func tutorialStep1() {
        boxes.map { $0.floatEnabled = false }
        buckets.map { $0.hidden = true }
        for bubble in bubbles {
            bubble.alpha = 1
            bubble.userInteractionEnabled = false
        }
        
        confirmButton.hidden = true
        helpText.hidden = false
        helpText.alpha = 0
        helpText.rawText = LS(R.Strings.threeMatchesPrompt)
        UIView.animateWithDuration(2) {
            self.helpText.alpha = 1
        }
        dropBubbles()
        tutorialStep = .Step1
    }
    
    // And you'll have three choices
    func tutorialStep2() {
        for bucket in buckets {
            bucket.hidden = false
            bucket.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            bucket.emphasized = true
        }
        helpText.alpha = 0
        helpText.rawText = LS(R.Strings.threeChoicesPrompt)
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 15, options: nil, animations: {
            self.buckets.map { $0.layer.transform = CATransform3DIdentity }
            return
            }, completion: nil)
        UIView.animateWithDuration(1) {
            self.bubbles.map { $0.alpha = 0.25 }
            self.helpText.alpha = 1
        }
        tutorialStep = .Step2
    }
    
    // Drag the match to your choices
    func tutorialStep3() {
        boxes.map { $0.floatEnabled = true }
        bubbles.map { $0.userInteractionEnabled = true }
        helpText.alpha = 0
        helpText.rawText = LS(R.Strings.dragMatchsToChoices)
        UIView.animateWithDuration(1) {
            self.buckets.map { $0.emphasized = false }
            self.bubbles.map { $0.alpha = 1 }
            self.helpText.alpha = 1
        }
        tutorialStep = .Step3
    }
}
