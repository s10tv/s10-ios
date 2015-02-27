//
//  WelcomeViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import SwipeView

@objc(WelcomeViewController)
class WelcomeViewController : BaseViewController, SwipeViewDelegate, SwipeViewDataSource {
    
    @IBOutlet var pages: [TransparentView]!

    @IBOutlet weak var swipeView: SwipeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pages.last?.whenSwiped(.Down, block: { [weak self] in
            let root = self?.navigationController as RootViewController
            root.showSignup(true)
        })
    }
    
    // MARK: - SwipeView
    
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return pages.count
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        return pages[index]
    }
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return swipeView.frame.size
    }
    
}
