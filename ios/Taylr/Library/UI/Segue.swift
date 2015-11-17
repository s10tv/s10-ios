//
//  Segue.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/6/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import QuartzCore

extension UIStoryboardSegue {
    var sourceVC : UIViewController { return sourceViewController }
    var destVC : UIViewController { return destinationViewController }
    var navVC : UINavigationController? { return sourceVC.navigationController }
}

// Specify objc class to work around Xcode's bug where dragging and dropping custom segue
// in swift modules does not store module name in IB by default and causes crash at runtime

@objc(WindowRootSegue)
public class WindowRootSegue : UIStoryboardSegue {
    public override func perform() {
        if let w = UIApplication.sharedApplication().delegate?.window, let window = w {
            destVC.view.frame = window.bounds
            UIView.transitionWithView(window, duration: 1, options: [.TransitionFlipFromRight], animations: {
                window.rootViewController = self.destVC
            }, completion: nil)
        }
    }
}


@objc(AdvancedPushSegue)
public class AdvancedPushSegue : UIStoryboardSegue {
    public enum ReplaceStrategy {
        case None, Last, Stack, BackStack([UIViewController])
    }
    public var animated = true
    public var replaceStrategy = ReplaceStrategy.None
    
    public override func perform() {
        if let navVC = navVC {
            switch replaceStrategy {
            case .None:
                navVC.pushViewController(destVC, animated: animated)
            case .Last:
                // Find better pattern for replace last element of an array?
                var vcs = navVC.viewControllers
                vcs.removeLast()
                vcs.append(destVC)
                navVC.setViewControllers(vcs, animated: animated)
            case .Stack:
                navVC.setViewControllers([destVC], animated: animated)
            case .BackStack(let backStack):
                navVC.setViewControllers(backStack + [destVC], animated: animated)
            }
        }
    }
}

@objc(UnwindPopSegue)
public class UnwindPopSegue : UIStoryboardSegue {
    public var animated = false
    
    public override func perform() {
        if let navVC = navVC {
            navVC.popToViewController(destVC, animated: animated)
        }
    }
}
