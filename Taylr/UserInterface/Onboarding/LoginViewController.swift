//
//  LoginViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import PKHUD
import DigitsKit
import ReactiveCocoa
import Meteor
import Core

class LoginViewController : BaseViewController {

    @IBOutlet weak var loginButton: DesignableButton!
    
    override func commonInit() {
        screenName = "Signup"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.whenLongPressEnded { [weak self] in self!.debugLogin(self!) }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SignupViewController {
            vc.viewModel = SignupInteractor(meteor: Meteor, user: Meteor.user.value!)
        }
        if let segue = segue as? LinkedStoryboardPushSegue where segue.matches(.Main_Discover) {
            segue.replaceStrategy = .Stack
        }
    }
    
    // MARK: Actions
        
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Globals.env.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Globals.env.privacyURL)
    }
    
    @IBAction func startLogin(sender: AnyObject) {
        if !Meteor.networkReachable {
            showErrorAlert(NSError(.NetworkUnreachable))
            return
        }
        Globals.accountService.login().on(UIScheduler(), success: {
            assert(NSThread.isMainThread(), "Only on main")
            switch Globals.accountService.state.value {
            case .LoggedIn:
                self.performSegue(.LoginToSignup, sender: self)
            case .SignedUp:
                self.performSegue(.Main_Discover, sender: self)
            default:
                break
            }
        }, failure: { error in
            if error.domain == METDDPErrorDomain {
                self.showAlert(LS(.errUnableToLoginTitle), message: LS(.errUnableToLoginMessage))
            } else if error.domain == DGTErrorDomain {
                // Ignoring digits error for now
                Log.warn("Ignoring digits error, not handling for now \(error)")
            }
        })
    }
    
    // MARK; - Debugging
    
    private func startLogin(loginBlock: () -> RACSignal, errorBlock: (NSError?) -> ()) {
        // TODO: We need to think about holistic, not just adhoc error handling
        if !Meteor.networkReachable {
            showErrorAlert(NSError(.NetworkUnreachable))
            return
        }
        PKHUD.showActivity()
        loginBlock().subscribeError({ error in
            PKHUD.hide()
            errorBlock(error)
            }, completed: {
                PKHUD.hide()
                self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
    @IBAction func debugLogin(sender: AnyObject) {
        Analytics.track("Debug Login Attempt")
        if !Meteor.settings.debugLoginMode {
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
                    self.showAlert("Failed to login", message: error?.localizedDescription ?? "Unknown Error")
                })
            }
        }
        presentViewController(alert)
    }
}