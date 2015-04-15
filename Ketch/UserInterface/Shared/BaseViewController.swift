//
//  BaseViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Meteor

class BaseViewController : UIViewController {
    
    var allowedStates: [FlowService.State]?
    
    private var stateDisposable: RACDisposable?
    private var metadataDisposable: RACDisposable?
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        return false
    }
    
    // MARK: - Initialization

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    override convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    func commonInit() { }
    
    // MARK: State Management
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        stateDisposable = Flow.stateSignal().subscribeNext { [weak self] _ in
            self!.stateDidUpdateWhileViewActive(Flow.currentState)
        }
        metadataDisposable = listenForNotification(METDatabaseDidChangeNotification)
            .deliverOnMainThread().subscribeNextAs { (notification: NSNotification) in
            if let changes = notification.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
                changes.affectedDocumentKeys().allObjects.filter {
                    ($0 as? METDocumentKey)?.collectionName == "metadata"
                }.map { $0.documentID as String }.each {
                    self.metadataDidUpdateWhileViewActive($0, value: Meteor.meta.getValue($0))
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stateDisposable?.dispose()
        metadataDisposable?.dispose()
    }
    
    func stateDidUpdateWhileViewActive(state: FlowService.State) {
        if let states = allowedStates {
            if !contains(states, state) {
                navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    func metadataDidUpdateWhileViewActive(metadataKey: String, value: AnyObject?) { }
    
    // MARK: Debugging
    
    override func motionEnded(subtype: UIEventSubtype, withEvent event: UIEvent) {
        if Env.audience == .Dev {
            if subtype == .MotionShake {
                navigationController?.popToRootViewControllerAnimated(true)
            }
            return
        }
        super.motionEnded(subtype, withEvent: event)
    }
}