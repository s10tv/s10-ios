//
//  ProfileViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import SwipeView
import SDWebImage

@objc(ProfileViewController)
class ProfileViewController : BaseViewController,
                              SwipeViewDelegate,
                              SwipeViewDataSource,
                              UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoCollection: UICollectionView!
    @IBOutlet weak var aboutLabel: DesignableLabel!
    
    var infoItems = ArrayViewModel(content: [ProfileInfoItem]())
    
    var user : User? {
        willSet {
            willChangeValueForKey("user")
        }
        didSet {
            didChangeValueForKey("user")
            if isViewLoaded() { reloadData() }
        }
    }
    
    convenience init(user: User) {
        self.init()
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Find better solution than hardcoding keypath string
        RAC(nameLabel, "text") <~ racObserve("user.displayName")
        RAC(aboutLabel, "rawText") <~ racObserve("user.about")

        infoItems.bindToCollectionView(infoCollection, cellNibName: "ProfileInfoCell")
        infoItems.collectionViewProvider?.configureCollectionCell = { item, cell in
            (cell as ProfileInfoCell).item = (item as ProfileInfoItem)
        }
        infoCollection.delegate = self
//        let layout = infoCollection.collectionViewLayout as UICollectionViewFlowLayout
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    // MARK: -
    
    @IBAction func goBack(sender: AnyObject) {
        dismissViewControllerAnimated(true)
    }
    
    func reloadData() {
        infoItems.content = user?.infoItems ?? []
        swipeView.reloadData()
        swipeView.scrollToItemAtIndex(0, duration: 0)
        pageControl.numberOfPages = numberOfItemsInSwipeView(swipeView)
        infoCollection.reloadData()
    }
}

// MARK: - Photos SwipeView Delegate / Data Source

extension ProfileViewController : SwipeViewDataSource {
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return user?.photos != nil ? (user?.photos?.count)! : 0
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let v = view != nil ? view as UIImageView : UIImageView()
        v.contentMode = .ScaleAspectFit
        let url = user?.photos![index].url
        v.sd_setImageWithURL(NSURL(string: url!))
        return v
    }
}

extension ProfileViewController : SwipeViewDelegate {
    func swipeViewCurrentItemIndexDidChange(swipeView: SwipeView!) {
        pageControl.currentPage = swipeView.currentPage
    }
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return swipeView.frame.size
    }
}

// MARK: Collection View Delegate

extension ProfileViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = infoItems.itemAtIndexPath(indexPath) as ProfileInfoItem
        var size = ProfileInfoCell.sizeForItem(item)
        size.width = between(collectionView.bounds.width * item.minWidthRatio,
            size.width,
            collectionView.bounds.width)
        return size
    }
}