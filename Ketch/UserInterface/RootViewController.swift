//
//  RootViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import Meteor
import FacebookSDK
import ReactiveCocoa

class RootViewController : UINavigationController {
    private let rootView = UIView.fromNib("RootView") as RootView
    var transitionManager : TransitionManager!
    
    override func loadView() {
        super.loadView()
        view.insertSubview(rootView, atIndex: 0)
        rootView.makeEdgesEqualTo(view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitionManager = TransitionManager(rootView: rootView, navigationController: self)
        
        view.whenEdgePanned(.Left) { [weak self] a, b in self!.handleEdgePan(a, edge: b) }
        view.whenEdgePanned(.Right) { [weak self] a, b in self!.handleEdgePan(a, edge: b) }
    }
    
    // MARK: Target Action
    
    func handleEdgePan(gesture: UIScreenEdgePanGestureRecognizer, edge: UIRectEdge) {
        switch gesture.state {
        case .Began:
            transitionManager.currentEdgePan = gesture
            if let vc = self.topViewController as? BaseViewController {
                vc.handleScreenEdgePan(edge)
            }
        case .Ended, .Cancelled:
            transitionManager.currentEdgePan = nil
        default:
            break
        }
    }
    
    @IBAction func goBack(sender: AnyObject) {
        if let vc = presentedViewController {
            dismissViewController(animated: true)
        } else {
            popViewControllerAnimated(true)
        }
    }
    
    func showNewMatch(connection: Connection) {
        let newConnVC = NewConnectionViewController()
        newConnVC.connection = connection
        presentViewController(newConnVC, animated: true)
    }
    
    @IBAction func logout(sender: AnyObject) {
        Account.logout().subscribeCompleted {
            Log.info("Signed out")
        }
        dismissViewController(animated: false)
        popToRootViewControllerAnimated(true)
    }
}
