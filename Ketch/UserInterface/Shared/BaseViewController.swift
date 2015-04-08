//
//  BaseViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

// TODO: This is used in conjunction with the RootViewController. Should it be 
// a protocol rather than a subclass?
class BaseViewController : UIViewController {
    
    var hideKetchBoat = true
    var waterlineLocation : RootView.WaterlineLocation = .Top(60)
    
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
}