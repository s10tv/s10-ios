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
import Bond

class DiscoverViewController : BaseViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    var discoverVM : DiscoverViewModel!
    var dataSourceBond: UICollectionViewDataSourceBond<UICollectionViewCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(inset: 5)
        collectionView.collectionViewLayout = layout

        dataSourceBond = UICollectionViewDataSourceBond(collectionView: collectionView)
        discoverVM = DiscoverViewModel()
        discoverVM.candidates.map { [unowned self] (vm, index) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(.CandidateCell,
                forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! CandidateCell
            cell.bindViewModel(vm)
            return cell
        } ->> dataSourceBond

        discoverVM.unreadConnectionsCount.map { $0 > 0 ? "Taylr (\($0))" : "Taylr" } ->> navigationItem.dynTitle
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController,
            let indexPath = collectionView.indexPathsForSelectedItems().first as? NSIndexPath,
            let user = discoverVM.candidates[indexPath.row].user {
            profileVC.profileVM = ProfileViewModel(meteor: Meteor, user: user)
        }
        if let meVC = segue.destinationViewController as? MeViewController {
            meVC.viewModel = MeViewModel(meteor: Meteor, currentUser: Meteor.user!)
        }
    }

    // MARK: - Actions
    
    @IBAction func unwindToDiscover(sender: UIStoryboardSegue) {
    }
}

extension DiscoverViewController : CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
//        CGSize size = CGSizeMake(arc4random() % 50 + 50, arc4random() % 50 + 50);
        return CGSize(width: 50, height: 80)
//        return CGSize(width: CGFloat(arc4random() % 30 + 50), height: CGFloat(arc4random() % 30 + 80))
    }
}