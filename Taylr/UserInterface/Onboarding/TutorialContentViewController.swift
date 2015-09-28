//
//  TutorialViewController.swift
//  S10
//
//  Created by Qiming Fang on 9/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Core
import ReactiveCocoa

protocol TutorialViewController {
    func getViewController() -> UIViewController
    func getIndex() -> Int
}

class TutorialContentViewController : BaseViewController, TutorialViewController {

    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var tutorialTitle: UILabel!
    @IBOutlet weak var tutorialImageView: UIImageView!

    var index = 0
    var titleText: String?
    var imageFile: String?
    var isLoginButtonHidden: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        tutorialTitle.textColor = UIColor.whiteColor()
        view.backgroundColor = UIColor.clearColor()

        tutorialImageView.image = UIImage(named: imageFile!)
        tutorialTitle.text = titleText

        loginButton.hidden = isLoginButtonHidden

        if isLoginButtonHidden == false {
            let vm = LoginViewModel(meteor: Meteor, delegate: Globals.accountService)
            loginButton.addAction(vm.loginAction) { values, errors, executing in
                showProgress <~ executing
                showErrorAction <~ errors.map { $0 as AlertableError }
                segueAction <~ values.map {
                    switch $0 {
                    case .LoggedIn: return .LoginToRegisterEmail
                    case .LoggedInButCodeDisabled: return .TutorialToConnectServices
                    case .Onboarded: return .Main_RootTab
                        // TODO: Fix me perma crash...
                    default: fatalError("Expecting either LoggedIn or Onboarded")
                    }
                }
            }
        }
    }

    func getViewController() -> UIViewController {
        return self as UIViewController
    }

    func getIndex() -> Int {
        return self.index
    }
}