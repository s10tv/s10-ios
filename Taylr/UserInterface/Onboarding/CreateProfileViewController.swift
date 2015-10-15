//
//  CreateProfileViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import JVFloatLabeledTextField
import PKHUD
import Core

class CreateProfileViewController : UITableViewController {
    @IBOutlet weak var coverCell: UITableViewCell!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var firstNameField: JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: JVFloatLabeledTextField!
    @IBOutlet weak var majorField: JVFloatLabeledTextField!
    @IBOutlet weak var yearField: JVFloatLabeledTextField!
    @IBOutlet weak var hometownField: JVFloatLabeledTextField!
    @IBOutlet weak var aboutView: JVFloatLabeledTextView!
    
    var vm: CreateProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fix for tableview layout http://stackoverflow.com/questions/18880341/why-is-there-extra-padding-at-the-top-of-my-uitableview-with-style-uitableviewst
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        // Give some room below aobutTextView
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

        avatarView.makeCircular()
        avatarView.sd_placeholderImage = avatarView.image
        coverView.sd_placeholderImage = coverView.image
        hometownField.setPlaceholder("Hometown", floatingTitle: "Hometown")
        aboutView.floatingLabelFont = UIFont(.cabinRegular, size: 11)
        aboutView.setPlaceholder("About (Optional)", floatingTitle: "About")
        aboutView.font = UIFont(.cabinRegular, size: 16)
        aboutView.delegate = self
        
        vm = CreateProfileViewModel(meteor: Meteor)
        firstNameField.rac_text <<~> vm.firstName
        lastNameField.rac_text <<~> vm.lastName
        hometownField.rac_text <<~> vm.hometown
        majorField.rac_text <<~> vm.major
        yearField.rac_text <<~> vm.year
        aboutView.rac_text <<~> vm.about
        avatarView.sd_image <~ vm.avatar
        coverView.sd_image <~ vm.cover
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: CreateProfile")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = true
            segue.replaceStrategy = .Stack
        }
        if let vc = segue.destinationViewController as? EditHashtagsViewController {
            // TODO: Instead of overreaching responsibility we should probably have a container view controller
            // for onboarding that contains the EditHastagsViewController but add additional information
            // to help user with first time experience.
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done,
                                                                    target: self, action: "didTapDoneOnEditHashtags:")
        }
    }

    // MARK: - Actions
    
    @IBAction func didTabEditAvatar(sender: AnyObject) {
        pickSingleImage(maxDimension: 640).onSuccess { image in
            self.vm.avatar.value = Image(image)
            self.execute(self.vm.uploadImageAction, input: (image, .ProfilePic), showProgress: true)
        }
    }
    
    @IBAction func didTabEditCover(sender: AnyObject) {
        pickSingleImage(maxDimension: 1400).onSuccess { image in
            self.vm.cover.value = Image(image)
            self.execute(self.vm.uploadImageAction, input: (image, .CoverPic), showProgress: true)
        }
    }

    @IBAction func didTapNext(sender: AnyObject) {
        wrapFuture(showProgress: true) {
            self.vm.saveProfile()
        }.onSuccess { [weak self] in
            self?.performSegue(SegueIdentifier.CreateProfiletoHashtag)
        }
    }
    
    @IBAction func didTapDoneOnEditHashtags(sender: AnyObject) {
        wrapFuture(showProgress: true) {
            self.vm.confirmRegistration()
        }.onSuccess {
            Analytics.track("Signup")
            // TODO: Maybe this should be in a segue from somewhere... Kind of harsh..
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
            let window = (UIApplication.sharedApplication().delegate?.window)!!
            UIView.transitionWithView(window, duration: 1, options: [.TransitionFlipFromRight], animations: {
                window.rootViewController = vc
            }, completion: nil)
        }
    }
}

// MARK: - Zoom in cover photo on tableView overscroll

extension CreateProfileViewController /*: UIScrollViewDelegate */ {
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
private let AboutIndexPath = NSIndexPath(forRow: 3, inSection: 1)

extension CreateProfileViewController /*: UITableViewDelegate */ {
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

