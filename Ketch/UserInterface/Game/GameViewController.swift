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
    
    @IBOutlet weak var container: UIView!
    @IBOutlet var gameView: GameView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet weak var dockBadge: UIImageView!
    
    var currentCandidates : [Candidate]? { didSet { candidatesDidChange() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKetchBoat = false
//        RAC(dockBadge, "hidden") <~ Connection.unreadCountSignal().map { ($0 as Int) == 0 }

        dockBadge.makeCircular()
        showSubview(gameView)

        bindGameView()
        gameView.didConfirmChoices = { [weak self] in
            if let this = self { this.submitChoices(this) }
        }
//        backgroundView.ketchIcon.userInteractionEnabled = true
//        backgroundView.ketchIcon.whenTapped {
//            self.gameView.tutorialStep1()
//        }
    }
    
    func bindGameView() {
        Core.candidateService.fetch.signal.subscribeNextAs { [weak self] (candidates : [Candidate]) in
            if let this = self {
                if candidates.count >= 3 {
                    this.currentCandidates = Array(candidates[0...2])
                } else {
                    this.currentCandidates = nil
                }
            }
        }
        // Setup tap to view profile
        for bubble in gameView.bubbles {
            bubble.didTap = { [weak self, weak bubble] _ in
                self?.showCandidateProfiles(bubble!.candidate!)
                return
            }
        }
    }
    
    func showCandidateProfiles(candidate: Candidate) {
        if let candidates = currentCandidates {
            let pageVC = PageViewController()
            pageVC.viewControllers = map(candidates) {
                return ProfileViewController(user: $0.user!)
            }
            pageVC.view.backgroundColor = StyleKit.skyColor
            pageVC.scrollTo(page: find(candidates, candidate)!, animated: false)
            presentViewController(pageVC, animated: true)
        }
    }
    
    func candidatesDidChange() {
        if let candidates = currentCandidates {
            assert(candidates.count == 3, "There must be exactly 3 candidates before starting game")
            showSubview(gameView)
            gameView.startNewGame(candidates)
        } else {
            showSubview(emptyView)
        }
    }
    
    // TODO: Should we refactor empty view into its own separate view controller?
    func showSubview(subview: UIView) {
        if subview.superview == nil {
            gameView.removeFromSuperview()
            emptyView.removeFromSuperview()
            container.addSubview(subview)
            subview.makeEdgesEqualTo(container)
        }
    }
    
    @IBAction func goToDock(sender: AnyObject) {
        performSegue(.GameToDock)
    }
    
    
    // MARK: -

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
    
}