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

    @IBOutlet var avatars: [MatchBubbleView]!
    
    @IBOutlet weak var marrySlot: UIImageView!
    @IBOutlet weak var keepSlot: UIImageView!
    @IBOutlet weak var skipSlot: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Core.matchService.fetch.signal.subscribeNextAs { (matches : [Match]) -> () in
            for (i, imageView) in enumerate(self.avatars) {
                if i < matches.count {
                    imageView.match = matches[i]
                    imageView.whenTapped {
//                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Profile") as ProfileViewController
                        let vc = NewConnectionViewController() as NewConnectionViewController
                        vc.user = matches[i].user
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    imageView.match = nil
                }
            }
        }
        
        // Setup Drag & Drop
        for imageView in self.avatars {
            imageView.userInteractionEnabled = true
            imageView.enableDragging()
            imageView.setDraggable(true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for imageView in avatars {
            imageView.contentMode = .ScaleToFill
            imageView.makeCircular()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }

    @IBAction func goToSettings(sender: AnyObject) {
        performSegueWithIdentifier("GameToSettings", sender: sender)
    }

    @IBAction func goToDock(sender: AnyObject) {
        performSegueWithIdentifier("GameToDock", sender: sender)
    }

    @IBAction func confirmChoices(sender: AnyObject) {
        var marry : Match?
        var keep : Match?
        var skip : Match?

        for avatar in self.avatars {
            let isMarry = CGRectIntersectsRect(avatar.frame, marrySlot.frame)
            let isKeep = CGRectIntersectsRect(avatar.frame, keepSlot.frame)
            let isSkip = CGRectIntersectsRect(avatar.frame, skipSlot.frame)
            if isMarry {
                marry = avatar.match
            } else if isKeep {
                keep = avatar.match
            } else if isSkip {
                skip = avatar.match
            }
        }
        if marry == nil || keep == nil || skip == nil {
            UIAlertView.show("Error", message: "Need to uniquely assign keep match marry")
        } else {
            Core.matchService.chooseYesNoMaybe(marry!, no: skip!, maybe: keep!).subscribeNextAs { (res : [String:String]) -> () in
                if res.count > 0 {
                    UIAlertView.show("Congrats", message: "You got \(res.count) matches")
                }
            }
        }
    }
    
}