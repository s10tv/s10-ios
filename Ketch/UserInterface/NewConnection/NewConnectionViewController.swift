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
    
    var connection: Connection!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatar: UserAvatarView!
    @IBOutlet weak var promptLabel: DesignableLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.didTap = { [weak self] user in
            let profileVC = ProfileViewController()
            profileVC.user = user
            self?.presentViewController(profileVC, animated: true)
        }
        titleLabel.text = LS(R.Strings.itsAKetch)
        avatar.user = connection.user
        promptLabel.rawText = LS(R.Strings.singleMatchPrompt, connection.user!.firstName!, connection.user!.firstName!)
    }
    
    @IBAction func goToDock(sender: AnyObject) {
        performSegue(.NewConnectionToDock)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatar.makeCircular()
    }
}