//
//  GameViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/10/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import UIView_draggable

@objc(GameViewController)
class GameViewController : BaseViewController {

    var backgroundView: KetchBackgroundView { return view as KetchBackgroundView }
    
    @IBOutlet var avatars: [UserAvatarView]!
    @IBOutlet var gameView: UIView!
    @IBOutlet var emptyView: UIView!
    
    @IBOutlet weak var marrySlot: UIImageView!
    @IBOutlet weak var keepSlot: UIImageView!
    @IBOutlet weak var skipSlot: UIImageView!
    @IBOutlet weak var dockBadge: UIImageView!
    var unreadConnections : FetchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Core.candidateService.fetch.signal.subscribeNextAs { [weak self] (candidates : [Candidate]) -> () in
            if let this = self {
                for (i, imageView) in enumerate(this.avatars) {
                    if i < candidates.count {
                        imageView.user = candidates[i].user
                    } else {
                        imageView.user = nil
                    }
                }
                this.showSubview(candidates.count > 3 ? this.gameView : this.emptyView)
            }
        }
        unreadConnections = FetchViewModel(frc: Connection.by(ConnectionAttributes.hasUnreadMessage.rawValue, value: true).frc())
        unreadConnections.signal.subscribeNext { [weak self] _ in
            if let this = self {
                let count = this.unreadConnections.objects.count
                this.dockBadge.hidden = count == 0
            }
        }
        unreadConnections.performFetchIfNeeded()
        
        // Setup Drag & Drop
        for imageView in self.avatars {
            imageView.enableDragging()
            imageView.setDraggable(true)
            imageView.didTap = { [weak self] user in
                if let vc = self?.storyboard?.instantiateViewControllerWithIdentifier("Profile") as? ProfileViewController {
                    vc.user = user
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        backgroundView.ketchIcon.userInteractionEnabled = true
        backgroundView.ketchIcon.whenTapped { [weak self] in
            if let this = self { this.confirmChoices(this) }
        }
        backgroundView.settingsButton.addTarget(self, action: "goToSettings:", forControlEvents: .TouchUpInside)
        backgroundView.dockButton.addTarget(self, action: "goToDock:", forControlEvents: .TouchUpInside)
        
        dockBadge.makeCircular()
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
        performSegueWithIdentifier("GameToSettings", sender: sender)
    }

    @IBAction func goToDock(sender: AnyObject) {
        performSegueWithIdentifier("GameToDock", sender: sender)
    }

    @IBAction func confirmChoices(sender: AnyObject) {
        var marry : Candidate?
        var keep : Candidate?
        var skip : Candidate?

        for avatar in self.avatars {
            let isMarry = CGRectIntersectsRect(avatar.frame, marrySlot.frame)
            let isKeep = CGRectIntersectsRect(avatar.frame, keepSlot.frame)
            let isSkip = CGRectIntersectsRect(avatar.frame, skipSlot.frame)
            if isMarry {
                marry = avatar.user?.candidate
            } else if isKeep {
                keep = avatar.user?.candidate
            } else if isSkip {
                skip = avatar.user?.candidate
            }
        }
        if marry == nil || keep == nil || skip == nil {
            UIAlertView.show("Error", message: "Need to uniquely assign keep match marry")
        } else {
            Core.candidateService.submitChoices(marry!, no: skip!, maybe: keep!).deliverOnMainThread().subscribeNextAs { (res : [String:String]) -> () in
                if res.count > 0 {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NewConnection") as NewConnectionViewController
                    vc.connections = map(res, { (key, value) -> Connection in
                        return Connection.findByDocumentID(value)!
                    })
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
}