//
//  Signup2ViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/2/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XLForm
import Core
import Bond
import PKHUD

class Signup2ViewController : XLFormViewController {
    
    var viewModel: SignupViewModel!
    
    override func viewDidLoad() {
        setupForm()
        super.viewDidLoad()
        // Fix for tableview layout http://stackoverflow.com/questions/18880341/why-is-there-extra-padding-at-the-top-of-my-uitableview-with-style-uitableviewst
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        return UnwindPopSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    }
    
    // MARK: -
    
    func setupForm() {
        form = XLFormDescriptor()
        
        let section1 = XLFormSectionDescriptor()
        let avatarCoverRow = XLFormPrototypeRowDescriptor(cellReuseIdentifier: TableViewCellreuseIdentifier.AvatarCoverCell.rawValue)
        avatarCoverRow.tag = "avatarCover"
        avatarCoverRow.title = "AvatarCover"
        section1.addFormRow(avatarCoverRow)
        form.addFormSection(section1)
        
        let section2 = XLFormSectionDescriptor()
        let firstNameRow = makeRow(.firstName, dynamic: viewModel.firstName, title: "First Name")
        firstNameRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        let lastNameRow = makeRow(.lastName, dynamic: viewModel.lastName, title: "Last Name")
        lastNameRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        let usernameRow = makeRow(.username, dynamic: viewModel.username, title: "Username")
        usernameRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        let aboutRow = makeRow(.about, dynamic: viewModel.about, title: "About Me", rowType: XLFormRowDescriptorTypeTextView)
        aboutRow.cellConfigAtConfigure["textView.placeholder"] = "Optional"
        [firstNameRow, lastNameRow, usernameRow, aboutRow].each {
            section2.addFormRow($0)
        }
        form.addFormSection(section2)
    }
    
    private func makeRow<T>(key: UserKeys, dynamic: Dynamic<T>, title: String, rowType: String = XLFormRowDescriptorTypeText) -> XLFormRowDescriptor {
        let row = XLFormRowDescriptor(tag: key.rawValue, rowType: rowType, title: title)
        dynamic.map { $0 as? AnyObject } ->> row
        return row
    }
    
    override func endEditing(rowDescriptor: XLFormRowDescriptor!) {
        super.endEditing(rowDescriptor)
        let editableKeys : [UserKeys] = [.firstName, .lastName, .about]
        if contains(editableKeys.map { $0.rawValue }, rowDescriptor.tag) {
            Meteor.updateProfile([rowDescriptor.tag: rowDescriptor.value ?? ""])
        }
    }
    
    // MARK: -
    
    @IBAction func submitRegistration(sender: AnyObject) {
        if view.endEditing(false) {
            if let username = form.formRowWithTag(UserKeys.username.rawValue).value as? String {
                println("Value \(username)")
                PKHUD.showActivity(dimsBackground: true)
                Meteor.confirmRegistration(username).deliverOnMainThread().subscribeError({ err in
                    PKHUD.hide(animated: false)
                    self.showErrorAlert(err)
                }, completed: {
                    PKHUD.hide(animated: false)
                    self.performSegue(.UnwindToLoading, sender: self)
                })
            }
        }
    }
}
