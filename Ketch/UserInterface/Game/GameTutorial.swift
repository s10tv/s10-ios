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

class GameTutorial {
    let gameVC: GameViewController
    private(set) var currentStep = 0
    let helpLabel: DesignableLabel
    let bubbles: [CandidateBubble]
    let placeholders: [ChoicePlaceholder]
    let overlay = TransparentView()
    
    var started : Bool { return currentStep > 0 }
    
    init(gameVC: GameViewController) {
        self.gameVC = gameVC
        self.helpLabel = gameVC.helpLabel
        self.bubbles = gameVC.bubbles
        self.placeholders = gameVC.placeholders
    }
    
    func setupTutorial() {
        placeholders.each { $0.hidden = true }
        bubbles.each { $0.hidden = true }
        gameVC.view.addSubview(overlay)
        
        overlay.makeEdgesEqualTo(gameVC.view)
        overlay.userInteractionEnabled = true
        overlay.passThroughTouchOnSelf = false
        overlay.whenTapEnded(advanceStep)
    }
    
    func startTutorial() {
        if currentStep == 0 {
            currentStep = 1
            advanceStep()
        }
    }
    
    func teardownTutorial() {
        placeholders.each { $0.hidden = false }
        bubbles.each { $0.hidden = false }
        overlay.removeFromSuperview()
        helpLabel.rawText = " "
    }
    
    func advanceStep() {
        println("Advancing to tutorial step \(currentStep)")
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
        currentStep++
    }
    
    // Helpers
    
    private func showHelpText(text: String) {
        helpLabel.alpha = 0
        helpLabel.rawText = text
        helpLabel.setHiddenAnimated(hidden: false, duration: 0.3)
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
        
        let arrowImage = UIImage(named: R.ImagesAssets.tutorialArrow)
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
