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
            if let vc = self?.makeViewController(.Profile) as? ProfileViewController {
                vc.user = user
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        titleLabel.text = LS(R.Strings.itsAKetch)
        avatar.user = connection.user
        promptLabel.rawText = LS(R.Strings.singleMatchPrompt, connection.user!.firstName!, connection.user!.firstName!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatar.makeCircular()
    }
    
    // MARK: - Actions
    
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func getInTouch(sender: AnyObject) {
        let dock = makeViewController(.Dock) as DockViewController
        let nav = navigationController
        nav?.popViewControllerAnimated(false)
        nav?.pushViewController(dock, animated: true)
    }
    
}