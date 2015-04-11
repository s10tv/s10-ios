//
//  BaseViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import ReactiveCocoa

// TODO: This is used in conjunction with the RootViewController. Should it be 
// a protocol rather than a subclass?
class BaseViewController : UIViewController {
    
    var hideKetchBoat = true
    var waterlineLocation : RootView.WaterlineLocation = .Top(60)
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
        stateDisposable = Core.flow.stateSignal().subscribeNext { [weak self] _ in
            self?.stateDidUpdateWhileViewActive(Core.flow.currentState)
            return
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stateDisposable?.dispose()
    }
    
    func stateDidUpdateWhileViewActive(state: FlowService.State) { }
}