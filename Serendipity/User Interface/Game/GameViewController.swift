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

    @IBOutlet var avatars: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Core.matchService.fetch.signal.subscribeNextAs { (matches : [Match]) -> () in
            for (i, imageView) in enumerate(self.avatars) {
                imageView.sd_setImageWithURL(matches[i].user?.profilePhotoURL)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for imageView in avatars {
            imageView.contentMode = .ScaleToFill
            imageView.makeCircular()
        }
    }
    
}