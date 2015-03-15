//
//  PageViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 3/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

class PageViewController : BaseViewController,
                           UIPageViewControllerDelegate,
                           UIPageViewControllerDataSource {
    
    private let pageVC = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    var viewControllers : [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageVC.delegate = self
        pageVC.dataSource = self
        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMoveToParentViewController(self)
    }
    
    func loadFirstPage(animated: Bool = false) -> RACSignal {
        let subject = RACReplaySubject()
        pageVC.setViewControllers([viewControllers[0]], direction: .Forward, animated: animated) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
    
    // MARK: Page View Controller Delegate / DataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let index = find(viewControllers, viewController) {
            return viewControllers.elementAtIndex(index - 1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let index = find(viewControllers, viewController) {
            return viewControllers.elementAtIndex(index + 1)
        }
        return nil
    }
}