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
    
    @IBOutlet var gameView: GameView!
    @IBOutlet var emptyView: UIView!
    
    @IBOutlet weak var dockBadge: UIImageView!
    var unreadConnections : FetchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Core.candidateService.fetch.signal.subscribeNextAs { [weak self] (candidates : [Candidate]) in
            if let this = self {
                if candidates.count >= 3 {
                    this.gameView.startNewGame(Array(candidates[0...2]))
                    this.showSubview(this.gameView)
                } else {
                    this.showSubview(this.emptyView)
                }
            }
        }
        // TODO: Make this 10x less verbose. Add some concept of reactive variable
        unreadConnections = FetchViewModel(frc: Connection.by(ConnectionAttributes.hasUnreadMessage.rawValue, value: true).frc())
        unreadConnections.signal.subscribeNext { [weak self] _ in
            if let this = self {
                let count = this.unreadConnections.objects.count
                this.dockBadge.hidden = count == 0
            }
        }
        unreadConnections.performFetchIfNeeded()
        
        // Setup Drag & Drop
        for source in self.gameView.sources {
            source.view.didTap = { [weak self] user in
                if let vc = self?.makeViewController(.Profile) as? ProfileViewController {
                    vc.user = user
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        backgroundView.settingsButton.addTarget(self, action: "goToSettings:", forControlEvents: .TouchUpInside)
        backgroundView.dockButton.addTarget(self, action: "goToDock:", forControlEvents: .TouchUpInside)
        
        dockBadge.makeCircular()
        showSubview(gameView)

        gameView.didConfirmChoices = { [weak self] in
            if let this = self { this.submitChoices(this) }
        }
    }
        
    func showSubview(subview: UIView) {
        if subview.superview == nil {
            gameView.removeFromSuperview()
            emptyView.removeFromSuperview()
            view.addSubview(subview)
            subview.makeEdgesEqualTo(view)
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
                    vc.connections = map(res, { (key, value) -> Connection in
                        return Connection.findByDocumentID(value)!
                    })
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
}