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

class RegisterEmailViewController : UIViewController {

    @IBOutlet weak var schoolNameField: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var emailField: UITextField!

    let vm = RegisterEmailViewModel(meteor: Meteor)

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.email <->> emailField
        vm.statusMessage ->> schoolNameField
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
        Globals.analyticsService.screen("Register School")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = true
            segue.replaceStrategy = .Stack
        }
    }

    // MARK: -

    @IBAction func didTapNext(sender: AnyObject) {
        wrapFuture {
            self.vm.saveEmail()
        }.onSuccess {
            self.performSegue(.RegisterEmailToConnectServices)
        }
    }
}