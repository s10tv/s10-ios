//
//  EditProfileViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/14/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Bond
import JVFloatLabeledTextField
import Core
import PKHUD

class EditProfileViewController : UITableViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameField: JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: JVFloatLabeledTextField!
    @IBOutlet weak var majorField: JVFloatLabeledTextField!
    @IBOutlet weak var gradYearField: JVFloatLabeledTextField!
    @IBOutlet weak var hometownField: JVFloatLabeledTextField!
    @IBOutlet weak var aboutTextView: JVFloatLabeledTextView!

    var servicesVC: IntegrationsViewController!
    var vm: EditProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fix for tableview layout http://stackoverflow.com/questions/18880341/why-is-there-extra-padding-at-the-top-of-my-uitableview-with-style-uitableviewst
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        coverImageView.clipsToBounds = true
        avatarImageView.makeCircular()
        
        vm.firstName <->> firstNameField
        vm.lastName <->> lastNameField
        vm.major <->> majorField
        vm.gradYear <->> gradYearField
        vm.hometown <->> hometownField
        vm.about <->> aboutTextView
        vm.avatar ->> avatarImageView.imageBond
        vm.cover ->> coverImageView.imageBond
        
        aboutTextView.font = UIFont(.cabinRegular, size: 16)
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Globals.analyticsService.screen("Edit Profile")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? IntegrationsViewController {
            servicesVC = vc
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didTapAvatarImageView(sender: AnyObject) {
        pickSingleImage(maxDimension: 640).onSuccess {
            let image = $0
            self.wrapFuture(showProgress: true) {
                self.vm.upload(image, taskType: .ProfilePic)
            }
        }
    }
    
    @IBAction func didTapCoverImageView(sender: AnyObject) {
        pickSingleImage(maxDimension: 1400).onSuccess {
            let image = $0
            self.wrapFuture(showProgress: true) {
                self.vm.upload(image, taskType: .CoverPic)
            }
        }
    }
    
    @IBAction func didPressDone(sender: AnyObject) {
        wrapFuture(showProgress: true) {
            vm.saveEdits()
        }.onSuccess {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}


extension EditProfileViewController : UITableViewDelegate {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: Should we consider autolayout?
        if indexPath.section == 1 { // Integrations section
            let height = servicesVC.collectionView!.collectionViewLayout.collectionViewContentSize().height + 20
            return height
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}