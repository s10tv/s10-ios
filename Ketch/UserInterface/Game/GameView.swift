//
//  GameView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class GameView : TransparentView {
    @IBOutlet var buckets: [ChoiceBucket]!
    @IBOutlet var boxes: [FloatBox]!
    @IBOutlet weak var helpText: DesignableLabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var bubbles: [CandidateBubble] = []

    override func commonInit() {
        super.commonInit()
        userInteractionEnabled = true
        passThroughTouchOnSelf = false
        for i in 0...2 {
            let bubble = CandidateBubble()
            addSubview(bubble)
            bubbles.append(bubble)
        }
    }
    
    var initialLayoutSet = false
    override func layoutSubviews() {
        super.layoutSubviews()
        println("layout pass triggering")
        if !initialLayoutSet {
            initialLayoutSet = true
            for (i, bubble) in enumerate(bubbles) {
                bubble.frame = self.boxes[i].frame
            }
        }
    }
    
    @IBAction func confirmChoices(sender: AnyObject) {
    }
}

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

class FloatBox : TransparentView { }

class SnapTarget {
    let center : CGPoint
    var bubble : CandidateBubble?
    var snap : UISnapBehavior?
    
    init(view: UIView) {
        center = view.center
    }
}