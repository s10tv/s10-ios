//
//  PlayerViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder

class PlayerViewController : UIViewController {

    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    var interactor: PlayerInteractor!
    
    @IBAction func didTapRewind(sender: AnyObject) {
        
    }

    @IBAction func didTapPlayOrPause(sender: AnyObject) {
        
    }
    
    @IBAction func didTapSkip(sender: AnyObject) {
        
    }
}