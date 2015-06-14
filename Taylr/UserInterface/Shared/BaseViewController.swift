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
    
    var screenName: String?
    
    private var metadataDisposable: RACDisposable?
    
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
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    func commonInit() { }
    
    // MARK: State Management
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = title
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        metadataDisposable = listenForNotification(METDatabaseDidChangeNotification)
            .deliverOnMainThread().subscribeNextAs { (notification: NSNotification) in
            if let changes = notification.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
                Array(changes.affectedDocumentKeys()).filter {
                    ($0 as! METDocumentKey).collectionName == "metadata"
                }.map { ($0 as! METDocumentKey).documentID as! String }.each {
                    self.metadataDidUpdateWhileViewActive($0, value: Meteor.meta.getValue($0))
                }
            }
        }
        if let screenName = screenName {
            Analytics.track("Screen: \(screenName)")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        metadataDisposable?.dispose()
    }
    
    func metadataDidUpdateWhileViewActive(metadataKey: String, value: AnyObject?) { }
    
    // MARK: Debugging
    
    override func motionEnded(subtype: UIEventSubtype, withEvent event: UIEvent) {
        if Meteor.meta.demoMode == true {
            if subtype == .MotionShake {
                navigationController?.popToRootViewControllerAnimated(true)
            }
            return
        }
        super.motionEnded(subtype, withEvent: event)
    }
}