//
//  GameView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class GameView : TransparentView {
    
    @IBOutlet var avatars: [UserAvatarView]!
    @IBOutlet weak var noBucket: UIImageView!
    @IBOutlet weak var maybeBucket: UIImageView!
    @IBOutlet weak var yesBucket: UIImageView!
    
    var sources : [AvatarSource]!
    var targets : [SnapTarget]!
    var animator : UIDynamicAnimator!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        animator = UIDynamicAnimator(referenceView: self)
        
        sources = map(avatars) { AvatarSource($0) }
        targets = map(sources as [AvatarSource], {
            SnapTarget(self.animator, position: $0.view.center, source: $0)
        })
        targets.extend(map([yesBucket, maybeBucket, noBucket], {
            SnapTarget(self.animator, position: $0.center, choice: self.choiceForBucket($0))
        }))
        
        let collision = UICollisionBehavior(items: avatars)
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
        for avatar in avatars {
            avatar.addGestureRecognizer(UIPanGestureRecognizer(
                target: self, action: "handleAvatarPan:"))
            avatar.userInteractionEnabled = true
        }
        userInteractionEnabled = true
    }
    
    func choiceForBucket(bucketView: UIImageView) -> Candidate.Choice? {
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
    
    func chosenCandidate(choice: Candidate.Choice?) -> Candidate? {
        for source in sources {
            if source.target?.choice == choice {
                return source.view.user?.candidate
            }
        }
        return nil
    }
    
    // TODO: Make game work for multiple screen sizes
    
    func handleAvatarPan(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(self)
        if let source = sources.filter({ $0.view == pan.view }).first {
            switch pan.state {
            case .Began:
                source.target = nil
                source.drag = UIAttachmentBehavior(item: source.view, attachedToAnchor: location)
                animator.addBehavior(source.drag)
            case .Changed:
                source.drag?.anchorPoint = location
            case .Ended:
                for s in sources {
                    animator.removeBehavior(s.drag)
                }
                let translation = pan.velocityInView(self) * velocityFactor
                let translatedCenter = source.view.center + translation
                for t in targets {
                    println("Option: \(t)")
                }
                let target = SnapTarget.closest(targets, point: translatedCenter)!
                willChangeValueForKey("isReady")
                source.target = target
                didChangeValueForKey("isReady")
                println("\tChosen: \(target)\n\tready: \(isReady)")
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
                if let view = source?.view {
                    snap = UISnapBehavior(item: view, snapToPoint: position)
                    animator.addBehavior(snap)
                }
            }
        }
        
        class func closest(targets: [SnapTarget], point: CGPoint) -> SnapTarget? {
            let eligible = targets.filter { $0.source == nil }
            return eligible.minElement { Float($0.position.distanceTo(point)) }
        }
    }
    
}