//
//  MeViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core
import SDWebImage
import Bond

class MeViewController : BaseViewController {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = Meteor.user
        if let currentUser = currentUser {
            currentUser.avatarURL.map { Optional($0) } ->> avatarView.dynImageURL
            currentUser.displayName ->> nameLabel
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.user = Meteor.user
        }
    }
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        Log.debug("Handding to edge \(edge) from dockVC")
        if edge == .Right {
            performSegue(.MeToDiscover)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
    
    @IBAction func showLogoutOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: LS(.settingsLogoutTitle), message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.settingsLogoutLogout)) { _ in
            Globals.accountService.logout()
            self.navigationController?.popToRootViewControllerAnimated(true)
//            self.performSegue(.SettingsToLoading)
        }
        sheet.addAction(LS(.settingsLogoutCancel), style: .Cancel)
        presentViewController(sheet)
    }

}