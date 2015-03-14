//
//  LoadingViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 3/10/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

@objc(LoadingViewController)
class LoadingViewController : BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Slightly hacky because it modifies internal state of another view. Need to think of better way
        let view = self.view as KetchBackgroundView
//        view.waveTopMargin.constant = view.waterlineLowerBound
    }
    
}