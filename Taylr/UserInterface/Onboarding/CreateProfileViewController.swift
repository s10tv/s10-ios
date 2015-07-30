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
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var firstNameField: JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: JVFloatLabeledTextField!
    @IBOutlet weak var taglineField: JVFloatLabeledTextField!
    @IBOutlet weak var aboutView: JVFloatLabeledTextView!
    
    let vm = CreateProfileViewModel(meteor: Meteor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarView.makeCircular()

        aboutView.floatingLabelFont = UIFont(.cabinRegular, size: 11)
        aboutView.setPlaceholder("About (Optional)", floatingTitle: "About")
        aboutView.font = UIFont(.cabinRegular, size: 16)
        aboutView.delegate = self
        
        vm.firstName <->> firstNameField
        vm.lastName <->> lastNameField
        vm.about <->> aboutView
        vm.tagline ->> taglineField
        vm.avatar ->> avatarView.imageBond
        vm.cover ->> coverView.imageBond
        // Give some room below aobutTextView
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Actions
    
    @IBAction func didTabEditAvatar(sender: AnyObject) {
        pickImage { image in
            let scaledImage = image.scaleToMaxDimension(20, pixelSize: true)
            PKHUD.showActivity(dimsBackground: true)
            self.vm.upload(scaledImage, taskType: .ProfilePic)
                |> deliverOn(UIScheduler())
                |> onComplete { result in
                if let error = result.error {
                    PKHUD.hide(animated: false)
                    self.showErrorAlert(error)
                } else {
                    PKHUD.showText("Cover Photo Updated")
                    PKHUD.hide(afterDelay: 0.5)
                }
            }
        }
    }
    
    @IBAction func didTabEditCover(sender: AnyObject) {
        pickImage { image in
            let scaledImage = image.scaleToMaxDimension(1400, pixelSize: true)
            PKHUD.showActivity(dimsBackground: true)
            self.vm.upload(scaledImage, taskType: .CoverPic)
                |> deliverOn(UIScheduler())
                |> onComplete { result in
                if let error = result.error {
                    PKHUD.hide(animated: false)
                    self.showErrorAlert(error)
                } else {
                    PKHUD.showText("Cover Photo Updated")
                    PKHUD.hide(afterDelay: 0.5)
                }
            }
        }
    }
}

// MARK: - Get AboutTextField's row to resize to fit content

// HACK ALERT: Better way than hardcode?
let AboutIndexPath = NSIndexPath(forRow: 3, inSection: 0)

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