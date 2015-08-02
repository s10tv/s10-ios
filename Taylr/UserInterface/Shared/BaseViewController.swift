//
//  BaseViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Meteor
import Core


extension UINavigationController {
    var lastViewController: UIViewController? {
        if viewControllers.count >= 2 {
            return viewControllers[viewControllers.count - 2] as? UIViewController
        }
        return nil
    }
}

class BaseViewController : UIViewController {
    // For docs see WWDC 2013 Session 218 Custom Transitions using View Controllers
    enum AppearanceState : Equatable {
        case Appearing(Bool) // Animated
        case Appeared
        case Disappearing(Bool) // Animated
        case Disappeared
    }
    
    private let _appearanceState = MutableProperty<AppearanceState>(.Disappeared)
    
    var appearanceState: PropertyOf<AppearanceState>!
    var showErrorAction: Action<AlertableError, Void, NoError>!
    var screenName: String?
    
    // MARK: - Initialization

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    func commonInit() {
        appearanceState = PropertyOf(_appearanceState)
        showErrorAction = Action<AlertableError, Void, NoError> { [weak self] error in
            return SignalProducer<Void, NoError> { [weak self] observer, disposable in
                let alert = error.alert
                let vc = UIAlertController(title: alert.title, message: alert.message, preferredStyle: alert.style)
                alert.actions.each {
                    vc.addAction($0)
                }
                self?.presentViewController(vc, animated: true) {
                    sendCompleted(observer)
                }
            }
        }
    }
        
    // MARK: State Management
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _appearanceState.value = .Appearing(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        _appearanceState.value = .Appeared
        screenName.map { Analytics.track("Screen: \($0)") }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _appearanceState.value = .Disappearing(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        _appearanceState.value = .Disappeared
    }
}

func == (lhs: BaseViewController.AppearanceState, rhs: BaseViewController.AppearanceState) -> Bool {
    switch (lhs, rhs) {
    case (.Appeared, .Appeared):
        return true
    case (.Disappeared, .Disappeared):
        return true
    case let (.Appearing(left), .Appearing(right)):
        return left == right
    case let (.Disappearing(left), .Disappearing(right)):
        return left == right
    default:
        return false
    }
}
