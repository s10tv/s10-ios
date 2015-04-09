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
    @IBOutlet var navViews: [UIView]!
    @IBOutlet weak var dockBadge: UIImageView!
    @IBOutlet var placeholders: [ChoiceBucket]!
    @IBOutlet var bubbles : [CandidateBubble]!
    @IBOutlet weak var helpLabel: DesignableLabel!
    @IBOutlet weak var confirmButton: DesignableButton!

    private var prelayoutBubbleCenters : [(CandidateBubble, CGPoint)]?
    
    var dynamics : UIDynamicAnimator!
    var targets : [SnapTarget]!
    var tutorialMode = UD[.bGameTutorialMode].bool!
    var readyToConfirm : Bool {
        return targets.filter { $0.choice != nil && $0.bubble != nil }.count == 3
    }
    var candidates : [Candidate]! {
        willSet { assert(candidates == nil, "candidates are immutable") }
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
    
    // Setup the game board once target positions can be acquired from autolayout
    // If game is already setup then opt-out of autolayout

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        prelayoutBubbleCenters = bubbles.map { ($0, $0.center) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if targets == nil {
            setupGame()
        } else {
            prelayoutBubbleCenters?.map { (bubble, center) in bubble.center = center }
        }
    }
    
    // MARK: - Game Setup & Start
    
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
        println("Setup game")
    }
    
    // MARK: - Core game mechanic
    
    // Snapping bubble to target will do three things
    // 1) Adding / removing snapping behavior
    // 2) Animating placeholder emphasis
    // 3) Animating confirm button visibilie
    private func assignBubbleToTarget(bubble: CandidateBubble, target: SnapTarget?) {
        func placeholderForTarget(target: SnapTarget?) -> ChoiceBucket? {
            return placeholders.match { $0.choice == target?.choice }
        }
        
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
        
        confirmButton.setHiddenAnimated(hidden: !readyToConfirm, delay: 0.3)
    }
    
    private func showHelpForTarget(target: SnapTarget?) {
        let helpText = target?.choice.map { (choice) -> String in
            switch choice {
            case .Yes:   return LS(R.Strings.marryPrompt)
            case .No:    return LS(R.Strings.skipPrompt)
            case .Maybe: return LS(R.Strings.snoozePrompt)
            }
        }
        helpLabel.rawText = helpText ?? helpLabel.rawText
        helpLabel.setHiddenAnimated(hidden: helpText == nil, duration: 0.3)
    }
    
    func handleBubblePan(pan: UIPanGestureRecognizer) {
        func closestTarget(point: CGPoint) -> SnapTarget {
            let freeTargets = targets.filter { $0.bubble == nil }
            return freeTargets.minElement { Float($0.center.distanceTo(point)) }!
        }
        
        var location = pan.locationInView(view)
        let bubble = pan.view as CandidateBubble
        
        switch pan.state {
        case .Began:
            // Remove Snap
            assignBubbleToTarget(bubble, target: nil)
            // Add Drag
            bubble.drag = UIAttachmentBehavior(item: bubble, attachedToAnchor: location)
            dynamics.addBehavior(bubble.drag)
        case .Changed:
            // Update Drag
            bubble.drag?.anchorPoint = location
            // Show help text
            showHelpForTarget(closestTarget(bubble.center))
        case .Ended:
            // Add Snap
            let target = closestTarget(bubble.center + pan.velocityInView(view) * 0.1)
            assignBubbleToTarget(bubble, target: target)
            // Remove Drag
            dynamics.removeBehavior(bubble.drag)
            // Hide help text
            showHelpForTarget(nil)
        default:
            break
        }
    }
    
    // MARK: - Navigation Logic
    
    @IBAction func submitChoices(sender: AnyObject) {
        assert(readyToConfirm, "Should not call submit choice until readyToConfirm")
        func chosenCandidate(choice: Candidate.Choice?) -> Candidate? {
            return targets.match { $0.choice == choice }?.bubble?.candidate
        }
        let marry = chosenCandidate(.Yes)!
        let keep = chosenCandidate(.Maybe)!
        let skip = chosenCandidate(.No)!
        Core.candidateService.submitChoices(yes: marry, no: skip, maybe: keep)
        // Go back to loading screen and let it handle the transition from there
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        if edge == .Right {
            performSegue(.GameToDock)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
    
    func didTapOnCandidateBubble(bubble: CandidateBubble) {
        let users = candidates.map { $0.user! }
        let index = find(candidates, bubble.candidate!)!
        let pageVC = ProfileViewController.pagedController(users, initialPage: index)
        presentViewController(pageVC, animated: true)
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
