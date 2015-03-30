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
    var currentViewController : UIViewController? {
        assert(pageVC.viewControllers.count <= 1, "Expecting at most 1 in viewControllers")
        return pageVC.viewControllers.last as UIViewController?
    }
    var currentPage : Int? {
        if let currentVC = currentViewController {
            return find(viewControllers, currentVC)
        }
        return nil
    }
    
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
    
    func scrollTo(#viewController: UIViewController, animated: Bool = false) -> RACSignal {
        let subject = RACReplaySubject()
        var direction = UIPageViewControllerNavigationDirection.Forward
        if let current = currentPage {
            if let page = find(viewControllers, viewController) {
                if current > page {
                    direction = .Reverse
                }
            }
        }
        
        pageVC.setViewControllers([viewController], direction: direction, animated: animated) { finished in
            subject.sendNextAndCompleted(finished)
        }
        return subject
    }
    
    func scrollTo(#page: Int, animated: Bool = false) -> RACSignal {
        return scrollTo(viewController: viewControllers[page], animated: animated)
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