//
//  VerifyCodeViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Core

class VerifyCodeViewController : UIViewController {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var verificationTokenField: UITextField!

    let vm = VerifyCodeViewModel(MainContext)

    override func viewDidLoad() {
        super.viewDidLoad()
        verificationTokenField.rac_text <<~> vm.code
        errorLabel.rac_text <~ vm.statusMessage
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        verificationTokenField.becomeFirstResponder()
        Analytics.track("View: VerifyInviteCode")
    }

    // MARK: -
    @IBAction func didPressShareButton(sender: AnyObject) {
        let shareText = "Anyone have a Taylr invite code?"
        let activity = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        presentViewController(activity)
    }

    @IBAction func didTapNext(sender: AnyObject) {
        wrapFuture {
            self.vm.verifyCode()
        }.onSuccess {
            self.performSegue(.RegisterEmailToConnectServices)
        }
    }
}