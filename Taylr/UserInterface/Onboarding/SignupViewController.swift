//
//  SignupViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/2/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import XLForm
import PKHUD
import Core

class SignupViewController : XLFormViewController {
    
    var viewModel: SignupInteractor!
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? LinkedStoryboardPushSegue where segue.matches(.Main_Discover) {
            segue.replaceStrategy = .Stack
        }
    }
    
    // MARK: -
    
    func setupForm() {
        form = XLFormDescriptor()
        
        let section1 = XLFormSectionDescriptor()
        let avatarCoverRow = PrototypeRow(cellReuseId: .AvatarCoverCell, tag: "avatarCover")
        avatarCoverRow.configure = { cell in
            if let cell = cell as? AvatarCoverCell {
                cell.avatarImageView.dynPlaceholderImage = cell.avatarImageView.image
                cell.coverImageView.dynPlaceholderImage = cell.coverImageView.image
                self.viewModel.coverURL ->> cell.coverImageView.dynImageURL
                self.viewModel.avatarURL ->> cell.avatarImageView.dynImageURL
            }
        }
        section1.addFormRow(avatarCoverRow)
        form.addFormSection(section1)
        
        let section2 = XLFormSectionDescriptor()
        let firstNameRow = makeRow(.firstName, dynamic: viewModel.firstName, title: "First Name")
        firstNameRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        firstNameRow.required = true
        let lastNameRow = makeRow(.lastName, dynamic: viewModel.lastName, title: "Last Name")
        lastNameRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        lastNameRow.required = true
        
        let usernameRow = makeRow(.username, dynamic: viewModel.username, title: "Username")
        usernameRow.cellConfigAtConfigure["textField.placeholder"] = "Required"
        usernameRow.required = true
        usernameRow.addValidator(XLFormRegexValidator(msg: "At least 5, max 16 characters, alphanumeric and _", andRegexString: "^[a-zA-Z\\d_]{5,16}$"))
        
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
    
    func pickImage(block: (UIImage) -> ()) {
        let picker = UIImagePickerController()
        picker.rac_imageSelectedSignal().subscribeNext({
            if let info = $0 as? NSDictionary,
                let image = (info[UIImagePickerControllerEditedImage]
                          ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
                block(image)
            }
            picker.dismissViewController(animated: true)
        }, completed: {
            picker.dismissViewController(animated: true)
        })
        presentViewController(picker, animated: true)
    }
    
    // MARK: -
    
    @IBAction func didTapAvatar(sender: AnyObject) {
        pickImage() { image in
            let scaledImage = image.scaleToMaxDimension(200, pixelSize: true)
            PKHUD.showActivity(dimsBackground: true)
            self.viewModel.uploadAvatar(scaledImage).subscribeErrorOrCompleted { err in
                PKHUD.showText("Success")
                PKHUD.hide(animated: false)
                if let err = err {
                    self.showErrorAlert(err)
                }
            }
        }
    }
    
    @IBAction func didTapCoverPhoto(sender: AnyObject) {
        pickImage() { image in
            let scaledImage = image.scaleToMaxDimension(1400, pixelSize: true)
            PKHUD.showActivity(dimsBackground: true)
            self.viewModel.uploadCoverPhoto(scaledImage).subscribeErrorOrCompleted { err in
                PKHUD.showText("Success")
                PKHUD.hide(animated: false)
                if let err = err {
                    self.showErrorAlert(err)
                }
            }
        }
    }
    
    // TODO: Move this method into the interactor
    @IBAction func submitRegistration(sender: AnyObject) {
        if let errors = formValidationErrors()?.map({ $0 as! NSError }) where errors.count > 0 {
            for error in errors {
                let validationStatus = error.userInfo![XLValidationStatusErrorKey] as! XLFormValidationStatus
                if let cell = self.tableView.cellForRowAtIndexPath(self.form.indexPathOfFormRow(validationStatus.rowDescriptor)) {
                    animateCell(cell)
                }
                if validationStatus.rowDescriptor.tag == UserKeys.username.rawValue {
                    // TODO: Better way to show error
                    showErrorAlert(error)
                }
            }
            return
        }
        
        if view.endEditing(false) {
            if viewModel.avatarURL.value == nil {
                showAlert("Avatar is required", message: "Please choose an avatar before proceeding")
                return
            }
            if let username = form.formRowWithTag(UserKeys.username.rawValue).value as? String {
                PKHUD.showActivity(dimsBackground: true)
                Meteor.confirmRegistration(username).deliverOnMainThread().subscribeError({ err in
                    PKHUD.hide(animated: false)
                    self.showErrorAlert(err)
                }, completed: {
                    PKHUD.hide(animated: false)
                    self.performSegue(.Main_Discover, sender: self)
                })
            }
        }
    }
    
    func animateCell(cell: UITableViewCell) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values =  [0, 20, -20, 10, 0]
        animation.keyTimes = [0, (1 / 6.0), (3 / 6.0), (5 / 6.0), 1]
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.additive = true
        cell.layer.addAnimation(animation, forKey: "shake")
    }
}
