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
        
        aboutTextView.floatingLabelFont = UIFont(.cabinRegular, size: 11)
        aboutTextView.font = UIFont(.cabinRegular, size: 16)
        aboutTextView.delegate = self
        
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

// HACK ALERT: Better way than hardcode?
private let AboutIndexPath = NSIndexPath(forRow: 3, inSection: 2)
private let IntegrationSection = 1

extension EditProfileViewController : UITableViewDelegate {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // TODO: Should we consider autolayout?
        if indexPath.section == IntegrationSection { // Integrations section
            let height = servicesVC.collectionView!.collectionViewLayout.collectionViewContentSize().height + 20
            return height
        }
        if let size = aboutTextView.superview?.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            where indexPath == AboutIndexPath {
                // NOTE: UITableViewAutomaticDimension doesn't work for reason not clear to me
                // +30 is a big hack, last line gets cut off for some reason otherwise...
                return size.height + 30
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}

extension EditProfileViewController : UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        // Force tableView to recalculate the height of the textView
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

