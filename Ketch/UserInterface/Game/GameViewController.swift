//
//  GameViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/10/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

@objc(GameViewController)
class GameViewController : BaseViewController {
    
    @IBOutlet weak var dockBadge: UIImageView!
    @IBOutlet var placeholders: [ChoiceBucket]!
    @IBOutlet var bubbles : [CandidateBubble]!
    @IBOutlet weak var helpLabel: DesignableLabel!
    @IBOutlet weak var confirmButton: DesignableButton!
    
    var tutorialMode = UD[.bGameTutorialMode].bool!
    var candidates : [Candidate]! {
        willSet { assert(candidates == nil, "candidates are immutable") }
    }
    var readyToConfirm : Bool {
        return targets.filter { $0.choice != nil && $0.bubble != nil }.count == 3
    }
    
    override func commonInit() {
        hideKetchBoat = false
    }
    
    override func viewDidLoad() {
        assert(candidates.count == 3, "Must provide 3 candidates before loading GameVC")
        super.viewDidLoad()

        // Setup bubbles
        for (i, bubble) in enumerate(bubbles) {
            bubble.candidate = candidates[i]
            // TODO: There is obvious memory leak here... Everything is retaining everything
            bubble.whenTapped {
                self.didTapOnCandidateBubble(bubble)
            }
            bubble.userInteractionEnabled = true
            bubble.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handleBubblePan:"))
        }
        
        helpLabel.hidden = true
        confirmButton.hidden = true
    }
    
    var dynamics : UIDynamicAnimator!
    var targets : [SnapTarget]!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if targets == nil {
            // Setup the game board once target positions can be acquired from autolayout
            setupGame()
        } else {
            // Override autolayout and manually positions the bubbles where they belong
            for target in targets {
                target.bubble?.center = target.center
            }
        }
    }
    
    private func setupGame() {
        targets = placeholders.map {
            SnapTarget(center: $0.center + CGPoint(x: 0, y: -11), choice: $0.choice)
        } + bubbles.map {
            SnapTarget(center: $0.center, choice: nil)
        }
        dynamics = UIDynamicAnimator(referenceView: view)
        dynamics.delegate = self
        let collision = UICollisionBehavior(items: bubbles)
        collision.setTranslatesReferenceBoundsIntoBoundaryWithInsets(UIEdgeInsets(inset: -50))
        collision.collisionMode = .Everything
        dynamics.addBehavior(collision)
    }
    
    // MARK: -
    
    private func closestTarget(point: CGPoint) -> SnapTarget {
        let freeTargets = targets.filter { $0.bubble == nil }
        return freeTargets.minElement { Float($0.center.distanceTo(point)) }!
    }
    
    private func placeholderForTarget(target: SnapTarget?) -> ChoiceBucket? {
        return placeholders.match { $0.choice == target?.choice }
    }
    
    private func snapBubbleToTarget(bubble: CandidateBubble, target: SnapTarget?) {
        let oldTarget = targets.match { $0.bubble == bubble }
        dynamics.removeBehavior(oldTarget?.snap)
        oldTarget?.snap = nil
        oldTarget?.bubble = nil
        placeholderForTarget(oldTarget)?.animateEmphasis(false)
        
        if let target = target {
            target.bubble = bubble
            target.snap = UISnapBehavior(item: bubble, snapToPoint: target.center)
            dynamics.addBehavior(target.snap)
            placeholderForTarget(target)?.animateEmphasis(true, delay: 0.2)
        }
        
        confirmButton.animateHidden(!readyToConfirm, delay: 0.1)
    }
    
    func handleBubblePan(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(view)
        let bubble = pan.view as CandidateBubble
        
        switch pan.state {
        case .Began:
            // Remove Snap
            snapBubbleToTarget(bubble, target: nil)
            // Add Drag
            bubble.drag = UIAttachmentBehavior(item: bubble, attachedToAnchor: location)
            dynamics.addBehavior(bubble.drag)
        case .Changed:
            // Update Drag
            bubble.drag?.anchorPoint = location
        case .Ended:
            // Add Snap
            let target = closestTarget(bubble.center + pan.velocityInView(view) * 0.1)
            snapBubbleToTarget(bubble, target: target)
            // Remove Drag
            dynamics.removeBehavior(bubble.drag)
        default:
            break
        }
    }
    
    // MARK: - 
    
    // TODO: This can be made much better. We should directly handle a candidate rather than user.candidate
    func didTapOnCandidateBubble(bubble: CandidateBubble) {
        let users = candidates.map { $0.user! }
        let index = find(candidates, bubble.candidate!)!
        let pageVC = ProfileViewController.pagedController(users, initialPage: index)
        presentViewController(pageVC, animated: true)
    }
    
    @IBAction func submitChoices(sender: AnyObject) {
        assert(readyToConfirm, "Should not call submit choice until readyToConfirm")
        func chosenCandidate(choice: Candidate.Choice?) -> Candidate? {
            return targets.match { $0.choice == choice }?.bubble?.candidate
        }
        let marry = chosenCandidate(.Yes)!
        let keep = chosenCandidate(.Maybe)!
        let skip = chosenCandidate(.No)!
        Core.candidateService.submitChoices(marry, no: skip, maybe: keep).deliverOnMainThread().subscribeNextAs { (res : [String:String]) -> () in
            if res.count > 0 {
                let connection = Connection.findByDocumentID(res["yes"]!)!
                self.rootVC.showNewMatch(connection)
            }
        }
    }

    // MARK: - Navigation Logic
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        if edge == .Right {
            performSegue(.GameToDock)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
}

extension GameViewController : UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        println("Dynamics did pause")
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
        println("Dynamics will resume")
    }
}
