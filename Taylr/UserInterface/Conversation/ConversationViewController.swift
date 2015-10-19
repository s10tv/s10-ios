//
//  ConversationViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/17/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Atlas
import Core

private let sb = UIStoryboard(name: "Conversation", bundle: nil)

class ConversationViewController : UIViewController {

    @IBOutlet weak var textSwitchButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var chatHistoryContainer: UIView!
    
    private(set) var chatHistoryVC: ConversationHistoryViewController!
    let producerVC = sb.makeViewController(.Producer) as! ProducerViewController
    let receiveVC = sb.makeViewController(.Receive) as! ReceiveViewController
    
    var vm: ConversationViewModel!
    var overlayVC: UIViewController? {
        didSet {
            if isViewLoaded() {
                if let oldVC = oldValue {
                    oldVC.willMoveToParentViewController(nil)
                    oldVC.view.removeFromSuperview()
                    oldVC.removeFromParentViewController()
                }
                if let newVC = overlayVC {
                    assert([producerVC, receiveVC].contains(newVC), "overlay must be either producerVC or receiveVC")
                    chatHistoryVC.messageInputToolbar.hidden = true
                    chatHistoryVC.messageInputToolbar.textInputView.resignFirstResponder()
                    
                    addChildViewController(newVC)
                    newVC.view.frame = view.bounds
                    view.insertSubview(newVC.view, aboveSubview: chatHistoryContainer)
                    newVC.view.makeEdgesEqualTo(view)
                    newVC.didMoveToParentViewController(self)
                } else {
                    chatHistoryVC.messageInputToolbar.hidden = false
                    chatHistoryVC.messageInputToolbar.textInputView.becomeFirstResponder()
                }
                // More of a hack here.
                textSwitchButton.hidden = (overlayVC != producerVC)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is necessary because otherwise during child viewWillAppear
        // the childVC's view will have the wrong frame
        avatarImageView.sd_image <~ vm.avatar
        titleLabel.rac_text <~ vm.displayName
        statusLabel.rac_text <~ vm.displayStatus
        
        receiveVC.vm = vm.receiveVM()
        receiveVC.delegate = self
        
        chatHistoryVC.view.makeEdgesEqualTo(chatHistoryContainer)
        
        if receiveVC.vm.playlist.array.count > 0 {
            overlayVC = receiveVC
        } else {
            overlayVC = producerVC
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundColor(UIColor(white: 0.5, alpha: 0.4))
        if let view = navigationItem.titleView {
            view.bounds.size = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundColor(nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if navigationController?.lastViewController is ProfileViewController {
            navigationController?.popViewControllerAnimated(true)
            return false
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationHistoryViewController {
            assert(vm != nil, "Conversation ViewModel must be set before prepareForSegue is called")
            vc.layerClient = MainContext.layer.layerClient
            vc.vm = vm
            vc.delegate = self
            vc.historyDelegate = self
            chatHistoryVC = vc
        }
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.vm = vm.profileVM()
        }
    }
    
    // MARK: -
    
    @IBAction func switchToHistory(sender: AnyObject) {
        overlayVC = nil
    }
    
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.viewProfile)) { _ in
            self.performSegue(.ConversationToProfile)
        }
        sheet.addAction(LS(.moreSheetBlock, vm.displayName.value), style: .Destructive) { _ in
            self.blockUser(self)
        }
        sheet.addAction(LS(.moreSheetReport, vm.displayName.value), style: .Destructive) { _ in
            self.reportUser(self)
        }
        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    // TODO: FIX CODE DUPLICATION WITH ProfileViewController
    @IBAction func blockUser(sender: AnyObject) {
        let alert = UIAlertController(title: "Block User",
            message: "Are you sure you want to block \(vm.displayName.value)?",
            preferredStyle: .Alert)
        alert.addAction("Cancel", style: .Cancel)
        alert.addAction("Block", style: .Destructive) { _ in
            self.vm.blockUser()
            Analytics.track("User: Block")
            let dialog = UIAlertController(title: "Block User", message: "\(self.vm.displayName.value) will no longer be able to contact you in the future", preferredStyle: .Alert)
            dialog.addAction("Ok", style: .Default)
            self.presentViewController(dialog)
            
        }
        presentViewController(alert)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
            if let reportReason = alert.textFields?[0].text {
                Analytics.track("User: Report", ["Reason": reportReason])
                self.vm.reportUser(reportReason)
            }
        }
        presentViewController(alert)
    }
}

extension ConversationViewController : ATLConversationViewControllerDelegate {
    func conversationViewController(viewController: ATLConversationViewController!, didSelectMessage message: LYRMessage!) {
        if message.containsVideo {
            overlayVC = receiveVC
        }
    }
}

extension ConversationViewController : ConversationHistoryDelegate {
    func didTapOnCameraButton() {
        overlayVC = producerVC
    }
}

extension ConversationViewController : ReceiveViewControllerDelegate {
    func didFinishPlaylist(receiveVC: ReceiveViewController) {
        overlayVC = producerVC
    }
}