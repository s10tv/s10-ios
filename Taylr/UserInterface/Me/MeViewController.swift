//
//  MeViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import ReactiveCocoa
import Argo
import Runes
import ObjectMapper
import Core

class MeViewController : UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var servicesContainer: UIView!
    @IBOutlet weak var inviteContainer: UIView!
    
    var servicesVC: IntegrationsViewController!
    var vm: MeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        
        vm = MeViewModel(meteor: Meteor, currentUser: Meteor.user.value!)
        vm.avatarURL ->> avatarView.dynImageURL
        vm.displayName ->> nameLabel
        vm.username ->> usernameLabel
        
        
        // Proactively improve shadow performance
        [servicesContainer, inviteContainer].each {
            $0.layer.shouldRasterize = true
            $0.layer.rasterizationScale = UIScreen.mainScreen().scale
        }

        // Observe collectionView height and reload table view cell height whenever appropriate
        servicesVC.collectionView!.dyn("contentSize").force(NSValue).producer
            |> skip(1)
            |> skipRepeats
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(next: { _ in
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            })
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
        if let vc = segue.destinationViewController as? IntegrationsViewController {
            servicesVC = vc
        }
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.profileVM = ProfileInteractor(meteor: Meteor, user: vm.currentUser)
        }
        if let vc = segue.destinationViewController as? EditProfileViewController {
            vc.interactor = EditProfileInteractor(meteor: Meteor, user: vm.currentUser)
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

extension MeViewController : UITableViewDelegate {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: Should we consider autolayout?
        if indexPath.section == 1 { // Integrations section
            let height = servicesVC.collectionView!.collectionViewLayout.collectionViewContentSize().height + 16
            return height
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}