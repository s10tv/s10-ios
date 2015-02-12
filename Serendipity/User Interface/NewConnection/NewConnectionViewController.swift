//
//  NewConnectionViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/12/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

@objc(NewConnectionViewController)
class NewConnectionViewController : BaseViewController {
    
    // TODO: Change this to connection later
    var user: User?
    
    @IBOutlet weak var avatarView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarView.sd_setImageWithURL(user?.profilePhotoURL)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarView.makeCircular()
    }
    
    @IBAction func getInTouch(sender: AnyObject) {
        
    }
    
}