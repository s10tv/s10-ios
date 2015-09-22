//
//  RootTabController.swift
//  S10
//
//  Created by Tony Xiao on 7/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Core

class RootTabController : UITabBarController {
    
    let vm = RootTabViewModel(meteor: Meteor, taskService: Globals.taskService)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = StyleKit.brandPurple
        navigationController?.navigationBarHidden = false
        delegate = self

        // Default to show Discover Scene first, then save user pref
        selectedIndex = UD.lastTabIndex.value ?? 1
        
        let nav = self.navigationController as? RootNavController
        Globals.accountService.state.producer
            |> takeWhile { $0.onboardingNeeded == false }
            |> start(completed: {
                nav?.goToLogin()
            })
        vm.chatsBadge.producer.start(next: { [weak self] badge in
            if let item = self?.tabBar.items?[2] as? UITabBarItem {
                item.badgeValue = badge
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let vc = selectedViewController {
            tabBarController(self, didSelectViewController: vc)
        }
    }
}

extension RootTabController : UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        tabBarController.navigationItem.title = viewController.title
        tabBarController.navigationItem.titleView = viewController.navigationItem.titleView
        tabBarController.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems
        tabBarController.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems
        UD.lastTabIndex.value = selectedIndex
    }
}