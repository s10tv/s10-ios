//
//  SignupViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import PKHUD
import ReactiveCocoa

class SignupViewController : BaseViewController {

    @IBOutlet weak var fullLogo: UIImageView!
    
    override func commonInit() {
        allowedStates = [.Signup]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Globals.env.audience == .Dev {
            fullLogo.userInteractionEnabled = true
            fullLogo.whenLongPressEnded { [weak self] in self!.debugLogin(self!) }
        }
    }
    
    private func startLogin(loginBlock: () -> RACSignal, errorBlock: (NSError) -> ()) {
        // Temp hack, timing issue
        allowedStates = [.Signup, .Waitlist, .Welcome]
        PKHUD.showActivity()
        loginBlock().subscribeError({ error in
            PKHUD.hide()
            errorBlock(error)
        }, completed: {
            PKHUD.hide()
            self.performSegue(.SignupToNotificationsPerm)
        })
    }
    
    // MARK: Actions
    
    @IBAction func didTapOnNotPicky(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Globals.env.notPickyExitURL)
    }
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Globals.env.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Globals.env.privacyURL)
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        startLogin({ Globals.accountService.login() }, errorBlock: { _ in
            self.performSegue(.SignupToFacebookPerm)
        })
    }
    
    @IBAction func debugLogin(sender: AnyObject) {
        if Globals.env.audience != .Dev {
            return
        }
        let alert = UIAlertController(title: "DEBUG LOGIN MODE", message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Enter target userId"
        }
        alert.addAction("Cancel", style: .Cancel)
        alert.addAction("Login") { [weak alert] _ in
            if let userId = (alert?.textFields?.first as? UITextField)?.text?.nonBlank() {
                self.startLogin({ Globals.accountService.debugLogin(userId) }, errorBlock: { error in
                    self.showAlert("Failed to login", message: error.localizedDescription)
                })
            }
        }
        presentViewController(alert)
    }
}