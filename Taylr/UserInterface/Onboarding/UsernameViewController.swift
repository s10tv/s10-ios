//
//  UsernameViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Bond
import Core
import ReactiveCocoa

class UsernameViewController : UIViewController {
 
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let vm = UsernameViewModel(meteor: Meteor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.placeholder = vm.usernamePlaceholder
        vm.username <->> usernameField
        vm.statusImage ->> statusImageView.imageBond
        vm.hideSpinner ->> spinner.dynHidden
        vm.statusMessage ->> statusLabel
        vm.statusColor ->> statusLabel.dynTextColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
        Globals.analyticsService.screen("Pick Username")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = true
            segue.replaceStrategy = .Stack
        }
    }

    // MARK: -
    
    @IBAction func didTapDone(sender: AnyObject) {
        wrapFuture(showProgress: true) {
            vm.saveUsername()
        }.onSuccess {
            self.performSegue(SegueIdentifier.Main_RootTab)
        }
    }
}