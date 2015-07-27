//
//  RootTabController.swift
//  S10
//
//  Created by Tony Xiao on 7/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Core

class RootTabController : UITabBarController {
    
    let vm = RootViewModel(meteor: Meteor, taskService: Globals.taskService)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = StyleKit.brandPurple
        navigationController?.navigationBarHidden = false
        delegate = self

        selectedIndex = 2// Discover Scene
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = selectedViewController?.title
        navigationItem.titleView = selectedViewController?.navigationItem.titleView
    }
}

extension RootTabController : UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        tabBarController.navigationItem.title = viewController.title
        tabBarController.navigationItem.titleView = viewController.navigationItem.titleView
    }
}