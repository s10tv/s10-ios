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
    
    @IBOutlet weak var dockBadge: UIImageView!
    var gameView: GameView! { return view as GameView }
    
    var candidates : [Candidate]! { willSet { assert(candidates == nil, "candidates are immutable") } }
    var bubbles : [CandidateBubble]!
    
    override func commonInit() {
        hideKetchBoat = false
    }
    
    override func viewDidLoad() {
        assert(candidates.count == 3, "Must provide 3 candidates before loading GameVC")
        super.viewDidLoad()
        
        bubbles = gameView.bubbles // TODO: Refactor me
        
        // Setup tap to view profile
        for (i, bubble) in enumerate(bubbles) {
            bubble.candidate = candidates[i]
            bubble.didTap = didTapOnUserBubble
        }
        gameView.didConfirmChoices = { [weak self] in
            if let this = self { this.submitChoices(this) }
        }

        gameView.helpText.hidden = true
        gameView.confirmButton.hidden = true
    }

    
    // MARK: -
    
    // TODO: This can be made much better. We should directly handle a candidate rather than user.candidate
    func didTapOnUserBubble(user: User?) {
        let users = candidates.map { $0.user! }
        let index = find(candidates, user!.candidate!)!
        let pageVC = ProfileViewController.pagedController(users, initialPage: index)
        presentViewController(pageVC, animated: true)
    }
    
    @IBAction func submitChoices(sender: AnyObject) {
        if !gameView.isReady {
            UIAlertView.show("Error", message: "Need to uniquely assign keep match marry")
        } else {
            let marry = gameView.chosenCandidate(.Yes)!
            let keep = gameView.chosenCandidate(.Maybe)!
            let skip = gameView.chosenCandidate(.No)!
            Core.candidateService.submitChoices(marry, no: skip, maybe: keep).deliverOnMainThread().subscribeNextAs { (res : [String:String]) -> () in
                if res.count > 0 {
                    let connection = Connection.findByDocumentID(res["yes"]!)!
                    self.rootVC.showNewMatch(connection)
                }
            }
        }
    }

    // MARK: - Navigation Logic
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        if edge == .Right {
            performSegue(.GameToDock)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
}