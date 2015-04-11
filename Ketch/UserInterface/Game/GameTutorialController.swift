//
//  GameTutorial.swift
//  Ketch
//
//  Created by Tony Xiao on 4/8/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import RBBAnimation
import Cartography
import Shimmer

class GameTutorialController {
    let gameVC: GameViewController
    var helpLabel: DesignableLabel { return gameVC.helpLabel }
    var bubbles: [CandidateBubble] { return gameVC.bubbles }
    var placeholders: [ChoicePlaceholder] { return gameVC.placeholders }
    var overlay : TransparentView!
    var prompt : FBShimmeringView!
    
    private(set) var currentStep = 0
    var started : Bool { return currentStep > 0 }
    
    init(gameVC: GameViewController) {
        self.gameVC = gameVC
        gameVC.delegate = self
    }
    
    func setupTutorial() {
        placeholders.each { $0.hidden = true }
        bubbles.each { $0.hidden = true }

        overlay = TransparentView()
        overlay.userInteractionEnabled = true
        overlay.passThroughTouchOnSelf = false
        overlay.whenTapEnded { [weak self] in self?.advanceStep(); return }
        gameVC.view.addSubview(overlay)

        let promptLabel = UILabel()
        promptLabel.text = LS(R.Strings.tapToContinue)
        promptLabel.font = UIFont(.TransatTextBlack, size: 20)
        promptLabel.textColor = StyleKit.darkWhite
        promptLabel.preferredMaxLayoutWidth = 200
        promptLabel.numberOfLines = 0
        promptLabel.textAlignment = .Center
        
        prompt = FBShimmeringView()
        prompt.contentView = promptLabel
        prompt.shimmering = true
        prompt.alpha = 0
        overlay.addSubview(prompt)
        
        overlay.makeEdgesEqualTo(gameVC.view)
        promptLabel.makeEdgesEqualTo(prompt)
        constrain(prompt, helpLabel) { prompt, helpLabel in
            prompt.bottom == helpLabel.top - 20
            prompt.centerX == helpLabel.centerX
        }
    }
    
    func startTutorial() {
        Log.info("Starting game tutorial")
        currentStep = 1
        advanceStep()
    }
    
    func teardownTutorial() {
        placeholders.each { $0.hidden = false }
        bubbles.each { $0.hidden = false }
        helpLabel.rawText = " "
        overlay.removeFromSuperview()
        overlay = nil
        prompt = nil
        currentStep = 0
    }
    
    func advanceStep() {
        Log.debug("Advancing to tutorial step \(currentStep)")
        switch currentStep {
        case 1:
            showHelpText(LS(R.Strings.threeMatchesPrompt))
        case 2:
            dropBubbles()
        case 3:
            showHelpText(LS(R.Strings.threeChoicesPrompt))
        case 4:
            popPlaceholders()
        case 5:
            showDragMatchesToChoices()
        default:
            setupTutorial()
            startTutorial()
            return // Should log warning
        }
        prompt.alpha = 0
        if currentStep < 5 {
            prompt.setHiddenAnimated(hidden: false, duration: 1, delay: 3)
        }
        currentStep++
    }
    
    // Helpers
    
    private func showHelpText(text: String) {
        helpLabel.alpha = 0
        helpLabel.rawText = text
        helpLabel.setHiddenAnimated(hidden: false, duration: 1)
    }
    
    private func dropBubbles() {
        for (i, bubble) in enumerate(bubbles) {
            let drop = RBBSpringAnimation(keyPath: "position.y")
            drop.fromValue = bubble.layer.position.y - gameVC.view.frame.height
            drop.toValue = bubble.layer.position.y
            drop.duration = 1
            drop.beginTime = CACurrentMediaTime() + 0.25 * Double(i)
            drop.fillMode = kCAFillModeBackwards
            drop.addToLayerAndReturnSignal(bubble.layer, forKey: "position.y")
            bubble.hidden = false
        }
    }
    
    private func popPlaceholders() {
        for (i, placeholder) in enumerate(placeholders) {
            placeholder.hidden = false
            placeholder.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            placeholder.alpha = 0
            UIView.animateSpring(1.5, damping: 0.3, velocity: 15, delay: 0.25 * Double(i)) {
                placeholder.alpha = 1
                placeholder.layer.transform = CATransform3DIdentity
                placeholder.emphasized = true
            }
        }
    }
    
    private func showDragMatchesToChoices() {
        UIView.animate(1) {
            self.placeholders.each { $0.emphasized = false }
        }
        showHelpText(LS(R.Strings.dragMatchsToChoices))
        
        let arrowImage = UIImage(named: R.KetchAssets.tutorialArrow)
        let centerBubble = bubbles[1]
        for i in -1...1 {
            let arrow = UIImageView(image: arrowImage)
            let angle = π/6 * i.f
            let distance = 10.f
            
            overlay.addSubview(arrow)
            constrain(arrow, centerBubble) { arrow, bubble in
                arrow.bottom == bubble.top - 20
                arrow.centerX == bubble.centerX + i.f * 40
            }
            arrow.transform = CGAffineTransformMakeRotation(angle)
            
            arrow.hidden = true
            arrow.setHiddenAnimated(hidden: false, duration: 0.25)
            
            let moveArrow = CABasicAnimation("position")
            moveArrow.byValue = CGPoint(x: sin(angle) * distance, y: -cos(angle) * distance).value
            moveArrow.duration = 2
            moveArrow.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            moveArrow.repeatCount = Float.infinity
            arrow.layer.addAnimation(moveArrow, forKey: "position")
        }
        
        overlay.passThroughTouchOnSelf = true
    }
}

extension GameTutorialController : GameViewControllerDelegate {
    func gameViewWillAppear(animated: Bool) {
        if UD[.bGameTutorialMode].bool! {
            if !started {
                setupTutorial()
            }
        } else {
            gameVC.tutorial = nil
            gameVC.delegate = nil
        }
    }
    
    func gameViewDidAppear(animated: Bool) {
        if !started {
            startTutorial()
        }
    }
    
    func gameDidAssignBubbleToTarget(bubble: CandidateBubble, target: SnapTarget?) {
        if target?.choice != nil && started {
            teardownTutorial()
            gameVC.tutorial = nil
            gameVC.delegate = nil
            UD[.bGameTutorialMode] = false
        }
    }
}