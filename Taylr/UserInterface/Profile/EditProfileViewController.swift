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
    @IBOutlet weak var aboutTextView: JVFloatLabeledTextView!
    @IBOutlet weak var usernameLabel: JVFloatLabeledTextField!
    
    var interactor: EditProfileInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fix for tableview layout http://stackoverflow.com/questions/18880341/why-is-there-extra-padding-at-the-top-of-my-uitableview-with-style-uitableviewst
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        coverImageView.clipsToBounds = true
        avatarImageView.makeCircular()
        
        interactor.firstName <->> firstNameField
        interactor.lastName <->> lastNameField
        interactor.about <->> aboutTextView
        interactor.username ->> usernameLabel
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func didPressDone(sender: AnyObject) {
        PKHUD.showActivity(dimsBackground: true)
        interactor.saveEdits().onComplete(UIScheduler()) { result in
            PKHUD.hide(animated: false)
            if let err = result.error {
                self.showErrorAlert(err)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
}