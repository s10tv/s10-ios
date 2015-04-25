//
//  PageViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 3/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

class PageViewController : BaseViewController {
    
    let pageVC = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    var viewControllers : [UIViewController] = []
    var currentViewController : UIViewController? {
        assert(pageVC.viewControllers.count <= 1, "Expecting at most 1 in viewControllers")
        return pageVC.viewControllers.last as! UIViewController?
    }
    var currentPage : Int? {
        if let currentVC = currentViewController {
            return find(viewControllers, currentVC)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageVC.dataSource = self
        pageVC.delegate = self
        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMoveToParentViewController(self)
    }
    
    func scrollTo(#viewController: UIViewController, animated: Bool = true) -> RACSignal {
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
    
    func scrollTo(#page: Int, animated: Bool = true) -> RACSignal {
        return scrollTo(viewController: viewControllers[page], animated: animated)
    }
    
}

// MARK: Page View Controller DataSource / Delegate

extension PageViewController : UIPageViewControllerDataSource {
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

extension PageViewController : UIPageViewControllerDelegate {
}