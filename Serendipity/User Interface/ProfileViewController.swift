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
class ProfileViewController : BaseViewController, SwipeViewDelegate, SwipeViewDataSource {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var swipeView: SwipeView!
    var user : User? {
        didSet {
            reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadData() {
        swipeView.reloadData()
        pageControl.numberOfPages = numberOfItemsInSwipeView(swipeView)
    }
    
    // MARK: - SwipeView Delegate / Data Soruce
    
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return user?.photos != nil ? (user?.photos?.count)! : 0
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let v = view != nil ? view as UIImageView : UIImageView()
        let url = (user?.photos as [Photo])[index].url
        v.sd_setImageWithURL(NSURL(string: url))
        return v
    }
    
    func swipeViewCurrentItemIndexDidChange(swipeView: SwipeView!) {
        pageControl.currentPage = swipeView.currentPage
    }
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return swipeView.frame.size
    }
    
}