//
//  DiscoverViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core
import CHTCollectionViewWaterfallLayout

class DiscoverViewController : BaseViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    var discoverVM : DiscoverViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(inset: 5)
        
        collectionView.collectionViewLayout = layout
        
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

extension DiscoverViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discoverVM.frc.fetchedObjects?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CandidateCell", forIndexPath: indexPath) as! CandidateCell
        cell.candidate = discoverVM.frc.objectAtIndexPath(indexPath) as? Candidate
        return cell
    }
}

extension DiscoverViewController : UICollectionViewDelegate {
    
}

extension DiscoverViewController : CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
//        CGSize size = CGSizeMake(arc4random() % 50 + 50, arc4random() % 50 + 50);
        
        return CGSize(width: CGFloat(arc4random() % 50 + 50), height: CGFloat(arc4random() % 50 + 50))
    }
}