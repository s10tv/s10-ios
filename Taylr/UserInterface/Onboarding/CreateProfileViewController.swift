//
//  CreateProfileViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class CreateProfileViewController : UITableViewController {
    
    @IBOutlet weak var firstNameField: JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: JVFloatLabeledTextField!
    @IBOutlet weak var taglineField: JVFloatLabeledTextField!
    @IBOutlet weak var aboutView: JVFloatLabeledTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutView.floatingLabelFont = UIFont(.cabinRegular, size: 11)
        aboutView.setPlaceholder("About (Optional)", floatingTitle: "About")
        aboutView.font = UIFont(.cabinRegular, size: 16)
        aboutView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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