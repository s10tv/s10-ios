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
    
    var connections: [Connection]?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftAvatar: UserAvatarView!
    @IBOutlet weak var centerAvatar: UserAvatarView!
    @IBOutlet weak var rightAvatar: UserAvatarView!
    @IBOutlet weak var promptLabel: DesignableLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if connections?.count == 1 {
            setupForSingleKetch()
        } else if connections?.count == 2 {
            setupForDoubleKetch()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in [leftAvatar, centerAvatar, rightAvatar] {
            view.didTap = { [weak self] user in
                if let vc = self?.storyboard?.instantiateViewControllerWithIdentifier("Profile") as? ProfileViewController {
                    vc.user = user
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    // Mark: -
    func setupForSingleKetch() {
        if let user = connections?.first?.user {
            titleLabel.text = "It's a Ketch!"
            centerAvatar.user = user
            // TODO: Move this into string file
            promptLabel.setRawText("It seems that \(user.firstName!) also thought you were pretty darn cute. Why not chat and see how things go?")
        }
    }
    
    func setupForDoubleKetch() {
        // TODO: Combine into single line using Swift 1.2
        if let user1 = connections?.first?.user {
            if let user2 = connections?.last?.user {
                titleLabel.text = "Lucky you!"
                leftAvatar.user = user1
                rightAvatar.user = user2
                promptLabel.setRawText("Both \(user1.firstName!) and \(user2.firstName!) were charmed by you. Why not get in touch and see how things go?")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func getInTouch(sender: AnyObject) {
        let dock = self.storyboard?.instantiateViewControllerWithIdentifier("Dock") as DockViewController
        let nav = navigationController
        nav?.popViewControllerAnimated(false)
        nav?.pushViewController(dock, animated: true)
    }
    
}