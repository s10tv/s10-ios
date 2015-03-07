//
//  GameView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

func DegreesToRadians (value:Int) -> CGFloat {
    return CGFloat(Double(value) * M_PI / 180.0)
}

class GameView : TransparentView, UIDynamicAnimatorDelegate {
    
    @IBOutlet var avatars: [UserAvatarView]!
    @IBOutlet weak var noBucket: UIImageView!
    @IBOutlet weak var maybeBucket: UIImageView!
    @IBOutlet weak var yesBucket: UIImageView!
    @IBOutlet weak var readyPrompt: TransparentView!
    
    var sources : [AvatarSource]!
    var targets : [SnapTarget]!
    var animator : UIDynamicAnimator!
    var collision : UICollisionBehavior!
    var velocityFactor : CGFloat = 0.1 // Multiplied with pan velocity to compute new pos
    var isReady : Bool {
        // TODO: Make this functional
        // Every target that has a choice also has an avatar source
        for target in targets {
            if (target.source != nil) != (target.choice != nil) {
                return false
            }
        }
        return true
    }
    var didConfirmChoices : (() -> ())?
    
    // TODO: Make game work for multiple screen sizes
    override func awakeFromNib() {
        super.awakeFromNib()
        
        passThroughTouchOnSelf = false
        
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        
        sources = map(avatars) { AvatarSource($0) }
        targets = map(sources as [AvatarSource], {
            SnapTarget(self.animator, position: $0.view.center, source: $0)
        })
        targets.extend(map([yesBucket, maybeBucket, noBucket], {
            SnapTarget(self.animator, position: $0.center + CGPointMake(0, -11),
                                        choice: self.choiceForBucket($0))
        }))
        
        collision = UICollisionBehavior(items: avatars)
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
//        let globalBehavior = UIDynamicItemBehavior(items: avatars)
//        globalBehavior.allowsRotation = false
//        animator.addBehavior(globalBehavior)
        
        for avatar in avatars {
            avatar.addGestureRecognizer(UIPanGestureRecognizer(
                target: self, action: "handleAvatarPan:"))
            avatar.userInteractionEnabled = true
        }
        userInteractionEnabled = true
        
        whenSwiped(.Down, block: { [weak self] in
            if let handler = self?.didConfirmChoices {
                if self!.isReady { handler() }
            }
        })
        
        RACSignal.interval(0.5, onScheduler: RACScheduler.mainThreadScheduler()).subscribeNext { [weak self] _ in
            if let this = self {
                for source in this.sources {
                    this.animator.removeBehavior(source.brownianPush)
                    if source.target?.choice == nil {
                        source.brownianPush = UIPushBehavior(items: [source.view], mode: .Instantaneous)
                        source.brownianPush!.magnitude = 0.1
                        source.brownianPush!.angle = DegreesToRadians(Int(arc4random()) % 360)
                        this.animator.addBehavior(source.brownianPush)
                    }
                }
            }
        }
    }
    
    func chosenCandidate(choice: Candidate.Choice?) -> Candidate? {
        for source in sources {
            if source.target?.choice == choice {
                return source.view.user?.candidate
            }
        }
        return nil
    }
    
    func startNewGame(candidates: [Candidate]) {
        assert(candidates.count == 3, "Must have exactly 3 candidates to start game")
        animator.removeBehavior(collision)
        let predecisionTargets = targets.filter { $0.choice == nil }
        for (i, source) in enumerate(sources) {
            source.view.user = candidates[i].user
            source.target = predecisionTargets[i]
        }
        readyPrompt.hidden = true
        
        RACSignal.interval(1, onScheduler: RACScheduler.mainThreadScheduler()).take(1).subscribeCompleted { [weak self] in
            self?.animator.addBehavior(self?.collision)
            return
        }
    }
    
    // MARK: -
    
    private func choiceForBucket(bucketView: UIImageView) -> Candidate.Choice? {
        switch bucketView {
        case yesBucket:
            return .Yes
        case maybeBucket:
            return .Maybe
        case noBucket:
            return .No
        default:
            return nil
        }
    }
    
    /*private*/ func handleAvatarPan(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(self)
        if let source = sources.filter({ $0.view == pan.view }).first {
            switch pan.state {
            case .Began:
                source.target = nil
                source.drag = UIAttachmentBehavior(item: source.view, attachedToAnchor: location)
                animator.addBehavior(source.drag)
                readyPrompt.hidden = true
            case .Changed:
                source.drag?.anchorPoint = location
            case .Ended:
                Log.debug("Options: \(targets)")
                for s in sources {
                    animator.removeBehavior(s.drag)
                }
                let translation = pan.velocityInView(self) * velocityFactor
                let translatedCenter = source.view.center + translation
                let target = SnapTarget.closest(targets, point: translatedCenter)!
                source.target = target
                readyPrompt.hidden = !isReady
                Log.debug("\tChosen: \(target)\n\tready: \(isReady)")
            default:
                break
            }
        }
    }
    
    // TODO: Make this subclass of UserAvatarView, implemnt drag behavior
    // Rename to something better like CandidateView
    // One way reference from target -> source to make it easier to maintain consistency
    class AvatarSource {
        let view : UserAvatarView
        var drag : UIAttachmentBehavior?
        var brownianPush : UIPushBehavior?
        var target : SnapTarget? { didSet { updateIfNeeded(oldValue) } }
        
        init(_ view: UserAvatarView) {
            self.view = view
            updateIfNeeded(nil)
        }
        
        func updateIfNeeded(oldTarget: SnapTarget?) {
            if (oldTarget !== target) {
                oldTarget?.source = nil
                target?.source = self
            }
        }
    }
    
    class SnapTarget : Printable {
        let animator : UIDynamicAnimator
        var position : CGPoint
        var snap : UISnapBehavior?
        var boundingBox : UICollisionBehavior?
        var choice: Candidate.Choice?
        var source: AvatarSource? { didSet { updateIfNeeded(oldValue) } }
        
        var description: String {
            return "SnapTarget<\(position), c:\(choice?.rawValue) s:\(source != nil)>"
        }
        
        init(_ animator: UIDynamicAnimator, position: CGPoint, choice: Candidate.Choice? = nil, source: AvatarSource? = nil) {
            self.animator = animator
            self.position = position
            self.choice = choice
            self.source = source
            updateIfNeeded(nil)
        }
        
        func updateIfNeeded(oldSource: AvatarSource?) {
            if oldSource !== source {
                source?.target = self
                animator.removeBehavior(snap)
                animator.removeBehavior(boundingBox)
                if let view = source?.view {
                    snap = UISnapBehavior(item: view, snapToPoint: position)
                    animator.addBehavior(snap)
                    if self.choice == nil {
                        RACSignal.interval(1, onScheduler: RACScheduler.mainThreadScheduler()).take(1).subscribeCompleted { [weak self] in
                            if let this = self {
                                this.animator.removeBehavior(this.snap)
                                let margin = CGFloat(80)
                                let top = this.position.y - margin
                                let bottom = this.position.y + margin
                                let left = this.position.x - margin
                                let right = this.position.x + margin
                                this.boundingBox = UICollisionBehavior(items: [view])
                                this.boundingBox!.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x: left, y: top), toPoint: CGPoint(x: right, y: top))
                                this.boundingBox!.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x: left, y: bottom), toPoint: CGPoint(x: right, y: bottom))
                                this.boundingBox!.addBoundaryWithIdentifier("left", fromPoint: CGPoint(x: left, y: top), toPoint: CGPoint(x: left, y: bottom))
                                this.boundingBox!.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x: right, y: top), toPoint: CGPoint(x: right, y: bottom))
                                this.animator.addBehavior(this.boundingBox)
                            }
                        }
                    }
                }
            }
        }
        
        class func closest(targets: [SnapTarget], point: CGPoint) -> SnapTarget? {
            let eligible = targets.filter { $0.source == nil }
            return eligible.minElement { Float($0.position.distanceTo(point)) }
        }
    }
    
}