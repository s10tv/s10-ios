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

class VerifyCodeViewController : UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var verificationTokenField: UITextField!

    let vm = VerifyCodeViewModel(meteor: Meteor)

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.code <->> verificationTokenField
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        verificationTokenField.becomeFirstResponder()
        Globals.analyticsService.screen("Verify Invite Code")
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
            self.vm.verifyCode()
        }.onSuccess {
            self.performSegue(.RegisterEmailToConnectServices)
        }
    }
}