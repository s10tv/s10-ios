//
//  TransitionManager.swift
//  Taylr
//
//  Created by Tony Xiao on 6/15/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import Core

class TransitionManager : NSObject, UINavigationControllerDelegate {
    var currentEdgePan : UIScreenEdgePanGestureRecognizer?
    
    init(navigationController: UINavigationController?) {
        super.init()
        navigationController?.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch (fromVC, toVC) {
        case (_ as DiscoverViewController, _ as MeViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .LeftToRight, panGesture: currentEdgePan)
        case (_ as MeViewController, _ as DiscoverViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .RightToLeft, panGesture: currentEdgePan)
        case (_ as DiscoverViewController, _ as ChatsViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .RightToLeft, panGesture: currentEdgePan)
        case (_ as ChatsViewController, _ as DiscoverViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .LeftToRight, panGesture: currentEdgePan)
            
        default:
            return nil
//            return WaveTransition(fromVC: fromVC, toVC: toVC, interactor: currentEdgePan.map { PanInteractor($0) })
        }
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? ViewControllerTransition)?.interactor
    }
}
