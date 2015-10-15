//
//  DiscoverViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import DZNEmptyDataSet
import Core

class DiscoverViewController : BaseViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    let vm = DiscoverViewModel(meteor: Meteor, taskService: Globals.taskService, layerService: Layer)
    
    deinit {
        collectionView?.delegate = nil
        collectionView?.emptyDataSetSource = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.emptyDataSetSource = self
        collectionView <~ (vm.candidate, TodayCell.self)
        vm.candidate.changes.observeNext { [weak self] _ in
            self?.collectionView.reloadEmptyDataSet()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Temporarily request all access to all permissions
        let settings = UIUserNotificationSettings(forTypes:[.Badge, .Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        Analytics.track("View: Today")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, // HACK ALERT: Hard-coded
                                                bottom: bottomLayoutGuide.length, right: 0)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(inset: 10)
        var itemSize = collectionView.bounds.insetBy(dx: 10, dy: 10).size
        itemSize.height -= bottomLayoutGuide.length
        layout.itemSize = itemSize
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController,
            let profileVM = vm.profileVM() {
            profileVC.vm = profileVM
            Analytics.track("Today: TapProfile")
        }
        if let vc = segue.destinationViewController as? ConversationViewController,
            let conversationVM = vm.conversationVM() {
            vc.vm = conversationVM
            Analytics.track("Today: TapMessage")
        }
        if let vc = segue.destinationViewController as? LayerConversationViewController {
            vc.layerClient = Layer.layerClient
            vc.conversation = vm.conversation()
        }
    }
}

extension DiscoverViewController : DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: LS(.emptyDiscoverMessage), attributes: [
            NSFontAttributeName: UIFont(.cabinRegular, size: 20)
        ])
    }
}
