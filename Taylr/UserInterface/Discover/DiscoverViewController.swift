//
//  DiscoverViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core

class DiscoverViewController : BaseViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    var discoverVM : DiscoverViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discoverVM = DiscoverViewModel()
        discoverVM.bindCollectionView(collectionView)
        Meteor.subscriptions.discover.signal.deliverOnMainThread().subscribeCompleted {
            self.discoverVM.frc.performFetch(nil)
            self.collectionView.reloadData()
        }
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

    // MARK: - Actions
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
    }
}