//
//  HomeViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/13/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class HomeViewController : BaseViewController {

    @IBOutlet var navViews: [UIView]!
    @IBOutlet weak var dockBadge: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        RAC(dockBadge, "hidden") <~ Connection.unreadCountSignal().map { ($0 as Int) == 0 }
    }
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        Log.debug("Handding to edge \(edge) from gameVC")
        if edge == .Right {
            performSegue(.HomeToDock)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
    }
    
}