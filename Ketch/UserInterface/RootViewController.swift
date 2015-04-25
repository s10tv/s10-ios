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
    var transitionManager : TransitionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleKit.white
        view.whenEdgePanned(.Left) { [weak self] a, b in self!.handleEdgePan(a, edge: b) }
        view.whenEdgePanned(.Right) { [weak self] a, b in self!.handleEdgePan(a, edge: b) }
        
        transitionManager = TransitionManager(navigationController: self)
    }
    
    // MARK: Target Action
    
    func handleEdgePan(gesture: UIScreenEdgePanGestureRecognizer, edge: UIRectEdge) {
        if Meteor.settings.edgePanEnabled != true {
            return
        }
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
    
}
