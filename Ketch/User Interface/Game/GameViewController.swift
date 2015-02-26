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

    @IBOutlet var avatars: [CandidateView]!
    
    @IBOutlet weak var marrySlot: UIImageView!
    @IBOutlet weak var keepSlot: UIImageView!
    @IBOutlet weak var skipSlot: UIImageView!
    @IBOutlet weak var ketchIcon: UIImageView!
    @IBOutlet weak var dockBadge: UIImageView!
    var unreadConnections : FetchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Core.candidateService.fetch.signal.subscribeNextAs { (candidates : [Candidate]) -> () in
            for (i, imageView) in enumerate(self.avatars) {
                if i < candidates.count {
                    imageView.candidate = candidates[i]
                    imageView.whenTapped {
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Profile") as ProfileViewController
                        vc.user = imageView.candidate?.user
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    imageView.candidate = nil
                }
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
            imageView.userInteractionEnabled = true
            imageView.enableDragging()
            imageView.setDraggable(true)
        }
        
        ketchIcon.userInteractionEnabled = true
        ketchIcon.whenTapped { [weak self] in
            self?.confirmChoices(self!)
            return
        }
        
        dockBadge.makeCircular()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for imageView in avatars {
            imageView.contentMode = .ScaleToFill
            imageView.makeCircular()
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
                marry = avatar.candidate
            } else if isKeep {
                keep = avatar.candidate
            } else if isSkip {
                skip = avatar.candidate
            }
        }
        if marry == nil || keep == nil || skip == nil {
            UIAlertView.show("Error", message: "Need to uniquely assign keep match marry")
        } else {
            Core.candidateService.submitChoices(marry!, no: skip!, maybe: keep!).deliverOnMainThread().subscribeNextAs { (res : [String:String]) -> () in
                if res.count > 0 {
                    let yesConnId = res["yes"]
                    let maybeConnId = res["maybe"]
                    let conn = Connection.findByDocumentID((yesConnId ?? maybeConnId)!)
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NewConnection") as NewConnectionViewController
                    vc.user = conn?.user
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
}