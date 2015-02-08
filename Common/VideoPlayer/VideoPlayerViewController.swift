//
//  VideoPlayerViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import MediaPlayer

@objc(VideoPlayerViewController)
class VideoPlayerViewController : BaseViewController {
    var moviePlayer : MPMoviePlayerController!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var movieView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let movieUrl = NSURL(string: "https://s10.blob.core.windows.net/s10-prod/12345/27372.m4v")!
        moviePlayer = MPMoviePlayerController(contentURL: movieUrl)
        moviePlayer.view.frame = CGRect(x: 0, y: 0, width: movieView.frame.width, height: movieView.frame.height)
        
        movieView.addSubview(moviePlayer.view)
        moviePlayer.fullscreen = true
    }
    
    @IBAction func onPlay(sender: AnyObject) {
        moviePlayer.play()
        
    }
    
}
