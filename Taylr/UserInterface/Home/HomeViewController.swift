//
//  HomeViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation

class HomeViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var feedVM: FeedViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedVM = FeedViewModel()
        feedVM.bindTableView(tableView)
    }
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        Log.debug("Handding to edge \(edge) from gameVC")
        if edge == .Right {
            performSegue(.DiscoverToChats)
            return true
        } else if edge == .Left {
            performSegue(.DiscoverToMe)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
}