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
    var sourceVC : UIViewController { return sourceViewController as UIViewController }
    var destVC : UIViewController { return destinationViewController as UIViewController }
    var navVC : UINavigationController? { return sourceVC.navigationController }
}

// TODO: Create Common framework and hide this class inside it
class _LinkedStoryboardSegue : UIStoryboardSegue {
    override init!(identifier: String!, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: _LinkedStoryboardSegue.sceneNamed(identifier))
    }
    
    class func sceneNamed(fullIdentifier: String) -> UIViewController {
        // TODO: Find better pattern for this ugly code
        let comps = fullIdentifier.componentsSeparatedByString("_")
        let storyboard = UIStoryboard(name: comps[0], bundle: nil)
        if let vcIdentifier = comps.count > 1 ? comps[1] : nil {
            if vcIdentifier.length > 0 {
                return storyboard.instantiateViewControllerWithIdentifier(vcIdentifier) as UIViewController
            }
        }
        return storyboard.instantiateInitialViewController() as UIViewController
    }
}

class LinkedStoryboardPushSegue : _LinkedStoryboardSegue {
    override func perform() {
        navVC?.pushViewController(destVC, animated: true)
    }
}

class LinkedStoryboardPresentSegue : _LinkedStoryboardSegue {
    override func perform() {
        sourceVC.presentViewController(destVC, animated: true, completion: nil)
    }
}

class ReplaceAndPushSegue : UIStoryboardSegue {
    override func perform() {
        if let navVC = navVC {
            // TODO: Find better pattern for replace last element of an array
            var vcs = navVC.viewControllers
            vcs.removeLast()
            vcs.append(destVC)
            navVC.setViewControllers(vcs, animated: true)
        }
    }
}

// TODO: Remove this class after we investigate CoreAnimation calls inside perform
class PushFromLeftSegue : UIStoryboardSegue {
    
    override func perform() {
        if let navVC = (self.sourceViewController as UIViewController).navigationController {
            let transition = CATransition()
            transition.duration = 0.25
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            navVC.view.layer.addAnimation(transition, forKey: kCATransition)
            navVC.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}
