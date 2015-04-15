//
//  TransitionManager.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class TransitionManager : NSObject, UINavigationControllerDelegate {
    var currentEdgePan : UIScreenEdgePanGestureRecognizer?
    
    init(navigationController: UINavigationController?) {
        super.init()
        navigationController?.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch (fromVC, toVC) {
            
        case let (fromVC as LoadingViewController, toVC as GameViewController):
            return NewGameTransition(fromVC: fromVC, toVC: toVC)

        case (_ as LoadingViewController, _ as NewConnectionViewController):
            return NewMatchTransition(fromVC: fromVC, toVC: toVC)
        
        case (_ as HomeViewController, _ as DockViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .RightToLeft, panGesture: currentEdgePan)
            
        case (_ as DockViewController, _ as HomeViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .LeftToRight, panGesture: currentEdgePan)
            
        default:
            return WaveTransition(fromVC: fromVC, toVC: toVC, interactor: currentEdgePan.map { PanInteractor($0) })
        }
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? ViewControllerTransition)?.interactor
    }
}

