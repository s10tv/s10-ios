//
//  ChatViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

@objc(ChatViewController)
class ChatViewController : BaseViewController {
    
    let player = VideoPlayerViewController()
    let recorder = VideoRecorderViewController()
    var connection: Connection?
    
    @IBOutlet weak var topContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(player)
        addChildViewController(recorder)
        showRecorder(nil)
    }
    
    @IBAction func showPlayer(sender: AnyObject?) {
        recorder.view.removeFromSuperview()
        topContainer.addSubview(player.view)
        player.view.makeEdgesEqualTo(topContainer)
    }
    
    @IBAction func showRecorder(sender: AnyObject?) {
        player.view.removeFromSuperview()
        topContainer.addSubview(recorder.view)
        recorder.view.makeEdgesEqualTo(topContainer)
    }
    
}
