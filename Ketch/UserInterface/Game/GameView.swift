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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sources = map(avatars) { AvatarSource($0) }
        targets = map(sources as [AvatarSource], {
            SnapTarget(position: $0.view.center, choice: nil, source: nil)
        })
        targets.extend(map([yesBucket, maybeBucket, noBucket], {
            SnapTarget(position: $0.center, choice: nil, source: nil)
        }))
        
        animator = UIDynamicAnimator(referenceView: self)
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
    
    // TODO: Make game work for multiple screen sizes
    
    func handleAvatarPan(pan: UIPanGestureRecognizer) {
        var location = pan.locationInView(self)
        if let source = sources.filter({ $0.view == pan.view }).first {
            switch pan.state {
            case .Began:
                animator.removeBehavior(source.target?.snap)
                source.drag = UIAttachmentBehavior(item: source.view, attachedToAnchor: location)
                animator.addBehavior(source.drag)
                source.target = nil
            case .Changed:
                source.drag?.anchorPoint = location
            case .Ended:
                for s in sources {
                    animator.removeBehavior(s.drag)
                }
                let translation = pan.velocityInView(self) * velocityFactor
                let translatedCenter = source.view.center + translation
                let target = SnapTarget.closest(targets, point: translatedCenter)!
                target.snap = UISnapBehavior(item: source.view, snapToPoint: target.position)
                animator.addBehavior(target.snap)
                source.target = target
            default:
                break
            }
        }
    }
    
    class SnapTarget : Printable {
        var position : CGPoint
        var choice: Candidate.Choice?
        var source: AvatarSource?
        var snap : UISnapBehavior?
        
        var description: String {
            return "SnapTarget<\(position)>"
        }
        
        init(position: CGPoint, choice: Candidate.Choice?, source: AvatarSource?) {
            self.position = position
            self.choice = choice
            self.source = source
        }
        
        class func closest(targets: [SnapTarget], point: CGPoint) -> SnapTarget? {
            let eligible = targets.filter { $0.source == nil }
            return eligible.minElement { Float($0.position.distanceTo(point)) }
        }
    }
    
    class AvatarSource : NSObject {
        let view : UserAvatarView
        var drag : UIAttachmentBehavior?
        var target : SnapTarget? {
            didSet {
                if (oldValue !== target) {
                    oldValue?.source = nil
                    target?.source = self
                }
            }
        }
        
        init(_ view: UserAvatarView) {
            self.view = view
        }
    }
}