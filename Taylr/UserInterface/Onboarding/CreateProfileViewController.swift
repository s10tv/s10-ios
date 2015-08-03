//
//  CreateProfileViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import ReactiveCocoa
import PKHUD
import Core
import Bond

class CreateProfileViewController : UITableViewController {
    
    @IBOutlet weak var coverCell: UITableViewCell!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var firstNameField: JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: JVFloatLabeledTextField!
    @IBOutlet weak var taglineField: JVFloatLabeledTextField!
    @IBOutlet weak var aboutView: JVFloatLabeledTextView!
    
    var vm: CreateProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fix for tableview layout http://stackoverflow.com/questions/18880341/why-is-there-extra-padding-at-the-top-of-my-uitableview-with-style-uitableviewst
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        // Give some room below aobutTextView
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

        avatarView.makeCircular()
        aboutView.floatingLabelFont = UIFont(.cabinRegular, size: 11)
        aboutView.setPlaceholder("About (Optional)", floatingTitle: "About")
        aboutView.font = UIFont(.cabinRegular, size: 16)
        aboutView.delegate = self
        
        vm = CreateProfileViewModel(meteor: Meteor)
        vm.firstName <->> firstNameField
        vm.lastName <->> lastNameField
        vm.about <->> aboutView
        vm.tagline <->> taglineField
        vm.avatar ->> avatarView.imageBond
        vm.cover ->> coverView.imageBond
        
//        Meteor.subscribe("me")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Actions
    
    @IBAction func didTabEditAvatar(sender: AnyObject) {
        pickImage { image in
            let scaledImage = image.scaleToMaxDimension(200, pixelSize: true)
            self.execute(self.vm.uploadImageAction, input: (scaledImage, .ProfilePic), showProgress: true)
        }
    }
    
    @IBAction func didTabEditCover(sender: AnyObject) {
        pickImage { image in
            let scaledImage = image.scaleToMaxDimension(1400, pixelSize: true)
            self.execute(self.vm.uploadImageAction, input: (scaledImage, .CoverPic), showProgress: true)
        }
    }

    @IBAction func didSelectNext(sender: AnyObject) {
        wrapFuture(vm.saveProfile(), showProgress: true).onSuccess { [weak self] in
            self?.performSegue(.Onboarding_profileToIntegrations)
        }
    }
}

// MARK: - Zoom in cover photo on tableView overscroll

extension CreateProfileViewController : UIScrollViewDelegate {
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if (yOffset < 0) {
            let originalHeight = coverCell.frame.height
            var frame = coverView.frame
            frame.origin.y = yOffset
            frame.size.height = originalHeight + -yOffset
            coverView.frame = frame
        }
    }
}

// MARK: - Get AboutTextField's row to resize to fit content

// HACK ALERT: Better way than hardcode?
let AboutIndexPath = NSIndexPath(forRow: 2, inSection: 1)

extension CreateProfileViewController : UITableViewDelegate {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let size = aboutView.superview?.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            where indexPath == AboutIndexPath {
                // NOTE: UITableViewAutomaticDimension doesn't work for reason not clear to me
                return size.height
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}


extension CreateProfileViewController : UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        // Force tableView to recalculate the height of the textView
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

