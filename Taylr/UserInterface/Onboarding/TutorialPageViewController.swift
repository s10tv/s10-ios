//
//  TutorialPageViewController.swift
//  S10
//
//  Created by Qiming Fang on 9/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import JBKenBurnsView
import Foundation
import UIKit

class TutorialPageContent {
    let title: String
    let imageFile: String
    init(title: String, imageFile: String) {
        self.title = title
        self.imageFile = imageFile
    }
}

class TutorialPageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?
    var contents : [TutorialPageContent] = [
        TutorialPageContent(
            title: "Connect your social accounts to get tailored matches.",
            imageFile: "onboarding-services"),
        TutorialPageContent(
            title: "Get introduced to one new classmate a day.",
            imageFile: "onboarding-profile"),
        TutorialPageContent(
            title: "Exchange messages and meet more classmates.",
            imageFile: "onboarding-connections")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self

        self.view.backgroundColor = UIColor.clearColor()

        let kenView = JBKenBurnsView(frame: view.frame)
        kenView.animateWithImages([
            UIImage(named: "onboarding-college1")!,
            UIImage(named: "onboarding-college2")!,
            UIImage(named: "onboarding-college3")!],
            transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)

        view.addSubview(kenView)
        view.sendSubviewToBack(kenView)

        let startingViewController = viewControllerAtIndex(0)
        let viewControllers = [startingViewController!]
        setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

        let pageControl = UIPageControl.appearance()
        pageControl.backgroundColor = UIColor.clearColor()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialViewController).getIndex()

        if index == 0 || index == NSNotFound {
            return nil
        }

        index--
        return viewControllerAtIndex(index)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialViewController).getIndex()

        if index == NSNotFound {
            return nil
        }

        index++
        if index == (contents.count + 1) {
            return nil
        }
        return viewControllerAtIndex(index)
    }

    func viewControllerAtIndex(index: Int) -> UIViewController? {
        if contents.count == 0 || index >= (contents.count + 1) {
            return nil
        }

        if (index == 0) {
            return storyboard?.instantiateViewControllerWithIdentifier("Login") as! LoginViewController
        } else {
            // the amount we need to offset because of special screens like login
            let contentIndex = index - 1;

            let pageContentViewController = storyboard?.instantiateViewControllerWithIdentifier("TutorialContentViewController") as! TutorialContentViewController

            let content = contents[contentIndex]

            pageContentViewController.titleText = content.title
            pageContentViewController.imageFile = content.imageFile

            if (contentIndex == contents.count - 1) {
                pageContentViewController.isLoginButtonHidden = false
            } else {
                pageContentViewController.isLoginButtonHidden = true
            }

            pageContentViewController.index = index
            return pageContentViewController

        }
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contents.count + 1 // for login
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}