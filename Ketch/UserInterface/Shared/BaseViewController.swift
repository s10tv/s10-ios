//
//  BaseViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import ReactiveCocoa

class BaseViewController : UIViewController {
    
    private var stateDisposable: RACDisposable?
    
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
            self?.stateDidUpdateWhileViewActive(Flow.currentState)
            return
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stateDisposable?.dispose()
    }
    
    func stateDidUpdateWhileViewActive(state: FlowService.State) { }
}