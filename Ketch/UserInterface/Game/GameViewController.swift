//
//  GameViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/10/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

protocol GameViewControllerDelegate : class {
    func gameViewWillAppear(animated: Bool)
    func gameViewDidAppear(animated: Bool)
    func gameDidAssignBubbleToTarget(bubble: CandidateBubble, target: SnapTarget?)
    func gameDidSubmitChoice()
}

class SnapTarget {
    let center : CGPoint
    let choice : Candidate.Choice?
    var bubble : CandidateBubble?
    var snap : UISnapBehavior?
    
    init(center: CGPoint, choice: Candidate.Choice?) {
        self.center = center
        self.choice = choice
    }
}

class GameViewController : HomeViewController {

    @IBOutlet var placeholders: [ChoicePlaceholder]!
    @IBOutlet var bubbles : [CandidateBubble]!
    @IBOutlet weak var helpLabel: DesignableLabel!
    @IBOutlet weak var confirmButton: DesignableButton!
    
    private var dynamics : UIDynamicAnimator!
    private var targets : [SnapTarget]!
    var readyToConfirm : Bool {
        return targets.filter { $0.choice != nil && $0.bubble != nil }.count == 3
    }
    var candidates : [Candidate]!
    
    var tutorial: GameTutorialController?
    weak var delegate: GameViewControllerDelegate?
    
    override func commonInit() {
        hideKetchBoat = false
        tutorial = GameTutorialController(gameVC: self)
    }
    
    override func viewDidLoad() {
        assert(candidates.count == 3, "Must provide 3 candidates before loading GameVC")
        super.viewDidLoad()
        
        // Setup bubble with candidates and event handling
        for (bubble, candidate) in Zip2(bubbles, candidates) {
            bubble.candidate = candidate
            bubble.whenTapped { [weak self] a in self?.handleBubbleTap(a); return }
            bubble.whenPanned { [weak self] a in self?.handleBubblePan(a); return }
        }
        
        helpLabel.hidden = true
        confirmButton.hidden = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.gameViewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.gameViewDidAppear(animated)
    }
    
    // MARK: - Game Layout Setup
    
    // Setup the game board once target positions can be acquired from autolayout
    // If game is already setup then opt-out of autolayout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        bubbles.map { $0.dynamicCenter = $0.center }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if targets == nil {
            initialLayoutGame()
        } else {
            bubbles.map { $0.center = $0.dynamicCenter! }
        }
    }
    
    private func initialLayoutGame() {
        dynamics = UIDynamicAnimator(referenceView: view)

        targets = placeholders.map {
            SnapTarget(center: $0.center + CGPoint(x: 0, y: -11), choice: $0.choice)
        }
        targets.extend(bubbles.map {
            let target = SnapTarget(center: $0.center, choice: nil)
            self.assignBubbleToTarget($0, target: target)
            return target
        })
        
        let collision = UICollisionBehavior(items: bubbles)
        collision.setTranslatesReferenceBoundsIntoBoundaryWithInsets(UIEdgeInsets(inset: -50))
        collision.collisionMode = .Everything
        dynamics.addBehavior(collision)
    }
    
    // MARK: - Core Game Mechanic
    
    // Snapping bubble to target will do three things
    // 1) Adding / removing snapping behavior
    // 2) Animating placeholder emphasis
    // 3) Animating confirm button visibilie
    // 4) Wiggle the bubble if it is being assigned to an empty target
    // 5) Stop any tutorial if user managed to assign to choice target
    private func assignBubbleToTarget(bubble: CandidateBubble, target: SnapTarget?) {
        func placeholderForTarget(target: SnapTarget?) -> ChoicePlaceholder? {
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
        
        bubble.setWigglingEnabled(target != nil && target?.choice == nil)
        confirmButton.setHiddenAnimated(hidden: !readyToConfirm, delay: 0.3)
        
        delegate?.gameDidAssignBubbleToTarget(bubble, target: target)
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
    
    func handleBubbleTap(tap: UITapGestureRecognizer) {
        if tap.state == .Ended {
            let users = candidates.map { $0.user! }
            let index = find(candidates, (tap.view as CandidateBubble).candidate!)!
            let pageVC = ProfileViewController.pagedController(users, initialPage: index)
            presentViewController(pageVC, animated: true)
        }
    }
    
    @IBAction func submitChoices(sender: AnyObject) {
        assert(readyToConfirm, "Should not call submit choice until readyToConfirm")
        func chosenCandidate(choice: Candidate.Choice?) -> Candidate? {
            return targets.match { $0.choice == choice }?.bubble?.candidate
        }
        let marry = chosenCandidate(.Yes)!
        let keep = chosenCandidate(.Maybe)!
        let skip = chosenCandidate(.No)!
        Flow.willSubmitGame()
        Meteor.submitChoices(yes: marry, no: skip, maybe: keep).subscribeNext({ newMatch in
            Flow.didReceiveGameResult(newMatch as? Connection)
        }, error: { error in
            Flow.didReceiveGameResult(nil)
            Log.error("Error receiving game result", error)
        })
        delegate?.gameDidSubmitChoice()
        performSegue(.FinishGame)
    }
}
