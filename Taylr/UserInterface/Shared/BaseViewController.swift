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
import Result
import PKHUD
import Core


extension UINavigationController {
    var lastViewController: UIViewController? {
        if viewControllers.count >= 2 {
            return viewControllers[viewControllers.count - 2] as? UIViewController
        }
        return nil
    }
}

extension UIViewController {
    func execute<T, E>(producer: SignalProducer<T, E>, showProgress: Bool = false) -> Disposable {
        return producer
            |> observeOn(UIScheduler())
            |> on(started: {
                    if showProgress { PKHUD.show(dimsBackground: true) }
                }, error: { [weak self] in
                    var alert: ErrorAlert?
                    if let e = $0 as? ActionError<E> {
                        switch e {
                        case .ProducerError(let e as AlertableError):
                            alert = e.alert
                        default:
                            break
                        }
                    }
                    if let e = $0 as? AlertableError {
                        alert = e.alert
                    }
                    if let alert = alert {
                        let vc = UIAlertController(title: alert.title, message: alert.message, preferredStyle: alert.style)
                        alert.actions.each { vc.addAction($0) }
                        self?.presentViewController(vc, animated: true, completion: nil)
                    }
                }, terminated: {
                    if showProgress { PKHUD.hide(animated: false) }
                })
            |> start()
    }
    
    func execute<I,O,E>(action: Action<I,O,E>, input: I, showProgress: Bool = false) -> Disposable {
        let producer = action.apply(input)
        return execute(producer, showProgress: showProgress)
    }
    
    func wrapFuture<T, E>(@autoclosure future: () -> Future<T, E>, showProgress: Bool = false ) -> Future<T, E> {
        let future = future()
        execute(future.producer, showProgress: showProgress)
        return future
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
    var segueAction: Action<SegueIdentifier, Void, NoError>!
    var showProgress: MutableProperty<Bool>!
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
        segueAction = Action { [weak self] identifier -> Result<Void, NoError> in
            self.map { $0.performSegue(identifier, sender: $0) }
            return Result(value: ())
        }
        showProgress = MutableProperty(false)
        combineLatest(appearanceState.producer, showProgress.producer)
            |> start(next: { state, executing in
                if state == .Appeared && executing {
                    PKHUD.showActivity(dimsBackground: true)
                } else {
                    PKHUD.hide(animated: false)
                }
            })
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
