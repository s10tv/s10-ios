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


extension UINavigationController {
    var lastViewController: UIViewController? {
        if viewControllers.count >= 2 {
            return viewControllers[viewControllers.count - 2] as? UIViewController
        }
        return nil
    }
}

class BaseViewController : UIViewController {
    
    var screenName: String?
    
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
        if let screenName = screenName {
            Analytics.track("Screen: \(screenName)")
        }
    }
}
