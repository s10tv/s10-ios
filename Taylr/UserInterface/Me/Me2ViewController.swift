//
//  Me2ViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import ReactiveCocoa
import Core

class Me2ViewController : UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var servicesContainer: UIView!
    @IBOutlet weak var inviteContainer: UIView!
    
    var servicesVC: ServicesViewController!
    var interactor: MeInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        
        interactor = MeInteractor(meteor: Meteor, taskService: Globals.taskService, currentUser: Meteor.user.value!)
        interactor.avatarURL ->> avatarView.dynImageURL
        interactor.displayName ->> nameLabel
        interactor.username ->> usernameLabel
        
        // Proactively improve shadow performance
        [servicesContainer, inviteContainer].each {
            $0.layer.shouldRasterize = true
            $0.layer.rasterizationScale = UIScreen.mainScreen().scale
        }
    }
    
    var hackedOffset = false
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         // Totally stupid hack, donno why needed, probably related to nesting TabBarViewController inside nav controller
        if !hackedOffset {
            hackedOffset = true
            tableView.contentOffset = CGPoint(x: 0, y: -66)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
            bottom: bottomLayoutGuide.length, right: 0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ServicesViewController {
            servicesVC = vc
        }
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.profileVM = ProfileInteractor(meteor: Meteor, user: interactor.currentUser)
        }
        if let vc = segue.destinationViewController as? EditProfileViewController {
            vc.interactor = EditProfileInteractor(meteor: Meteor, user: interactor.currentUser)
        }
        if let segue = segue as? LinkedStoryboardPushSegue where segue.matches(.Onboarding_Login) {
            segue.replaceStrategy = .Stack
        }
    }
    
    // MARK: -
    
    @IBAction func didPressContactSupport(sender: AnyObject) {
        let alert = UIAlertController(title: "To be implemented", message: nil, preferredStyle: .Alert)
        alert.addAction("Ok", style: .Cancel)
        presentViewController(alert)
    }
    
    @IBAction func didPressLogout(sender: AnyObject) {
        let sheet = UIAlertController(title: LS(.settingsLogoutTitle), message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.settingsLogoutLogout)) { _ in
            Globals.accountService.logout()
            self.performSegue(.Onboarding_Login, sender: self)
        }
        sheet.addAction(LS(.settingsLogoutCancel), style: .Cancel)
        presentViewController(sheet)
    }
}

extension Me2ViewController : UITableViewDelegate {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: Should we consider autolayout?
        if indexPath.section == 1 { // Services section
            return servicesVC.collectionView!.collectionViewLayout.collectionViewContentSize().height + 16 // Padding
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}