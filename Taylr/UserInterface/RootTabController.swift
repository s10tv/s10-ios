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
        
        Globals.accountService.state.producer
            .takeWhile { $0.onboardingNeeded == false }
            .startWithCompleted {
                let vc = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()!
                let window = (UIApplication.sharedApplication().delegate?.window)!!
                UIView.transitionWithView(window, duration: 1, options: [.TransitionFlipFromRight], animations: {
                    window.rootViewController = vc
                }, completion: nil)
            }
        vm.chatsBadge.producer.startWithNext { [weak self] badge in
            if let item = self?.tabBar.items?[2] {
                item.badgeValue = badge
            }
        }
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
        UD.lastTabIndex.value = selectedIndex
    }
}