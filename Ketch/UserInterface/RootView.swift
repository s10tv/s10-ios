//
//  RootView.swift
//  Ketch
//
//  Created by Tony Xiao on 3/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

/*
// loading -> signup
    water bottom -> top, no boat
// loading -> game
    water bottom -> top, with boat
// game -> boat has sailed
    water top -> bottom -> boat sails -> back up with new boat has sailed view
// game -> new match
    water top -> bottom -> back up to center with bouncing avatar ball
// game <-> dock <-> chat
    water remains top, but moves laterally with boat moving out of the way
// game <-> settings
    water top -> bottom and remains bottom, presentation rather than scrolling
// game <-> profile
    avatar bubble -> expands to profile photo -> shirnks back down to avatar bubble
    water moves top -> midway point
// chat <-> profile
    top avatar -> expands to profile photo -> shrinks back down to top avatar
    water moves top -> midway point
// settings <-> profile
    avatar -> expands to profile photo -> shrinks back down to avatar
    water moves bottom -> midway point
*/

class RootView : BaseView {
    
    @IBOutlet weak var ketchIcon: UIImageView!
    @IBOutlet weak var waveView: WaveView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet private weak var horizonHeight: NSLayoutConstraint!

    var animateDuration : NSTimeInterval = 0.6
    var springDamping : CGFloat = 0.6
    var initialSpringVelocity : CGFloat = 10
    
    @IBInspectable var ketchIconHidden : Bool {
        get { return ketchIcon.hidden }
        set(newValue) { ketchIcon.hidden = newValue }
    }
    
    private func animateLayoutChange() -> RACSignal {
        let subject = RACReplaySubject()
        UIView.animateWithDuration(animateDuration, delay: 0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: nil, animations: {
            self.layoutIfNeeded()
        }, completion: { finished in
            subject.sendNextAndCompleted(finished)
        })
        return subject
    }

    func animateHorizon(#ratio: CGFloat) -> RACSignal {
        assert(between(0, ratio, 1) == true, "Ratio must be between 0 and 1")
        // Question: Do we need separate constraint for ratio or convert to offset like below?
        horizonHeight.constant = frame.height * ratio
        return animateLayoutChange()
    }
    
    func animateHorizon(#offset: CGFloat, fromTop: Bool = true) -> RACSignal {
        horizonHeight.constant = fromTop ? frame.height - offset : offset
        return animateLayoutChange()
    }
    
    func animateWaterlineDownAndUp(completion: ((Bool) -> ())? = nil) {
        animateHorizon(offset: 100, fromTop: false).subscribeCompleted {
            self.animateHorizon(offset: 60)
            return
        }
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup boat pitching animation
        let pitch = CABasicAnimation(keyPath: "transform.rotation")
        pitch.fromValue = 0.2
        pitch.toValue = -0.2
        pitch.autoreverses = true
        pitch.duration = 3
        pitch.repeatCount = Float.infinity
        ketchIcon.layer.addAnimation(pitch, forKey: "pitching")
    }
}
