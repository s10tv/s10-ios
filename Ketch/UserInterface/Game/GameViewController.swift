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

    var backgroundView: KetchBackgroundView { return view as KetchBackgroundView }
    
    @IBOutlet weak var container: UIView!
    @IBOutlet var gameView: GameView!
    @IBOutlet var emptyView: UIView!
    
    @IBOutlet weak var dockBadge: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RAC(dockBadge, "hidden") <~ Connection.unreadCountSignal().map { ($0 as Int) == 0 }

        dockBadge.makeCircular()
        showSubview(gameView)

        bindGameView()
        gameView.didConfirmChoices = { [weak self] in
            if let this = self { this.submitChoices(this) }
        }
        backgroundView.ketchIcon.userInteractionEnabled = true
        backgroundView.ketchIcon.whenTapped {
            self.gameView.tutorialStep1()
        }
    }
    
    func bindGameView() {
        Core.candidateService.fetch.signal.subscribeNextAs { [weak self] (candidates : [Candidate]) in
            if let this = self {
                if candidates.count >= 3 {
                    this.showSubview(this.gameView)
                    this.gameView.startNewGame(Array(candidates[0...2]))
                    this.backgroundView.animateWaterlineDownAndUp()
                } else {
                    this.showSubview(this.emptyView)
                }
            }
        }
        // Setup tap to view profile
        for bubble in gameView.bubbles {
            bubble.didTap = { [weak self] user in
                if let vc = self?.makeViewController(.Profile) as? ProfileViewController {
                    vc.user = user
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func showSubview(subview: UIView) {
        if subview.superview == nil {
            gameView.removeFromSuperview()
            emptyView.removeFromSuperview()
            container.addSubview(subview)
            subview.makeEdgesEqualTo(container)
        }
    }
    
    // MARK: -

    @IBAction func goToSettings(sender: AnyObject) {
        performSegue(.GameToSettings, sender: sender)
    }

    @IBAction func goToDock(sender: AnyObject) {
        performSegue(.GameToDock, sender: sender)
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
                    let vc = self.makeViewController(.NewConnection) as NewConnectionViewController
                    vc.connection = Connection.findByDocumentID(res["yes"]!)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
}