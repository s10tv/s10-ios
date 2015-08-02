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
import Bond
import Core

class LoginViewController : BaseViewController {

    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    let vm = LoginViewModel(delegate: Globals.accountService)
    
    override func commonInit() {
        super.commonInit()
        screenName = "Login"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.loginButtonText ->> loginButton.titleBond
        vm.logoutButtonText ->> logoutButton.titleBond
        vm.loginAction <~ loginButton
        vm.logoutAction <~ logoutButton
        showProgress <~ vm.loginAction.executing
        showErrorAction <~ vm.loginAction.mErrors |> map { $0 as AlertableError }
        segueAction <~ vm.loginAction.mValues |> map {
            switch $0 {
            case .LoggedIn: return .LoginToCreateProfile
            case .Onboarded: return .Main_RootTab
            default: fatalError("Expecting either LoggedIn or Onboarded")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? LinkedStoryboardPushSegue where segue.matches(.Main_RootTab) {
            segue.replaceStrategy = .Stack
        }
    }
    
    // MARK: Actions
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(vm.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(vm.privacyURL)
    }
}