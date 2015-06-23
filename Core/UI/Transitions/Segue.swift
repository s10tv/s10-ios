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
    var sourceVC : UIViewController { return sourceViewController as! UIViewController }
    var destVC : UIViewController { return destinationViewController as! UIViewController }
    var navVC : UINavigationController? { return sourceVC.navigationController }
}

// Specify objc class to work around Xcode's bug where dragging and dropping custom segue
// in swift modules does not store module name in IB by default and causes crash at runtime
@objc(LinkedStoryboardPushSegue)
class LinkedStoryboardPushSegue : UIStoryboardSegue {
    override init!(identifier: String!, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: loadSceneNamed(identifier))
    }
    
    override func perform() {
        navVC?.pushViewController(destVC, animated: true)
    }
}

@objc(LinkedStoryboardPresentSegue)
class LinkedStoryboardPresentSegue : UIStoryboardSegue {
    override init!(identifier: String!, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: loadSceneNamed(identifier))
    }

    override func perform() {
        sourceVC.presentViewController(destVC, animated: true, completion: nil)
    }
}

@objc(ReplaceAndPushSegue)
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

// Loading ViewController instance from storyboard with format ${StoryboardName}_${ViewControllerIdentifier}
private func loadSceneNamed(fullIdentifier: String) -> UIViewController {
    // TODO: Find better pattern for this ugly code
    let comps = fullIdentifier.componentsSeparatedByString("_")
    let storyboard = UIStoryboard(name: comps[0], bundle: nil)
    if let vcIdentifier = comps.count > 1 ? comps[1] : nil {
        if vcIdentifier.length > 0 {
            return storyboard.instantiateViewControllerWithIdentifier(vcIdentifier) as! UIViewController
        }
    }
    return storyboard.instantiateInitialViewController() as! UIViewController
}

// TODO: Remove this class after we investigate CoreAnimation calls inside perform
class PushFromLeftSegue : UIStoryboardSegue {
    
    override func perform() {
        if let navVC = (self.sourceViewController as! UIViewController).navigationController {
            let transition = CATransition()
            transition.duration = 0.25
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            navVC.view.layer.addAnimation(transition, forKey: kCATransition)
            navVC.pushViewController(destinationViewController as! UIViewController, animated: false)
        }
    }
}
