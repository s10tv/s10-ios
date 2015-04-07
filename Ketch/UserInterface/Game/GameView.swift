//
//  GameView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class ChoiceBucket : UIImageView {
    var choice : Candidate.Choice!
    var bubble: CandidateBubble?
    var emphasized: Bool = false { didSet { updateAlphaAndTint() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image = image?.imageWithRenderingMode(.AlwaysTemplate)
        updateAlphaAndTint()
    }
    
    func updateAlphaAndTint() {
        if emphasized {
            alpha = 1
            tintColor = UIColor.whiteColor()
        } else {
            alpha = 0.4
            tintColor = StyleKit.teal
        }
    }
}

class SnapTarget {
    let center : CGPoint
    var bubble : CandidateBubble?
    var snap : UISnapBehavior?
    
    init(view: UIView) {
        center = view.center
    }
}
