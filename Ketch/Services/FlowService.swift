//
//  FlowService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/7/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor

// FlowService manages the different states user can be in taking into account everything going on in the app

class FlowService : NSObject {
    enum State : String {
        case Loading = "Loading"
        case Signup = "Signup"
        case Error = "Error"
        case Waitlist = "Waitlist"
        case Welcome = "Welcome"
        case BoatSailed = "BoatSailed"
        case NewMatch = "NewMatch"
        case NewGame = "NewGame"
    }
    
    private let ms: MeteorService
    private let stateChanged = RACSubject()
    private var demoState: State?
    private var waitingOnGameResult = false // Waiting to hear back from server about recent game
    private(set) var newMatchToShow : Connection?
    private(set) var candidateQueue : [Candidate]?
    private(set) var currentState = State.Loading
    private(set) var error: NSError?
    
    var loginComplete: Bool {
        return !ms.loggingIn &&
            ms.subscriptions.metadata.ready &&
            ms.subscriptions.settings.ready &&
            ms.subscriptions.currentUser.ready &&
            ms.subscriptions.candidates.ready &&
            ms.subscriptions.connections.ready &&
            ms.settings.vetted != nil
    }
    var hasConnections: Bool { return Connection.count() > 0 }
    var canPlayNewGame: Bool { return Candidate.count() >= 3 }

    
    init(meteorService: MeteorService) {
        self.ms = meteorService
        super.init()
        meteorService.delegate = self
        listenForNotification(METDatabaseDidChangeNotification, selector: "meteorDatabaseDidChange:")
        listenForNotification(METDDPClientDidChangeAccountNotification, selector: "meteorAccountDidChange:")
    }
    
    // Due to RAC's current constraint we are not able to send enum as value, so sending nil for now
    // to indicate state changed but to get the state changed to simply access flow service
    func stateSignal() -> RACSignal {
        return stateChanged.startWith(nil).deliverOnMainThread()
    }
    
    // Explicit API to update components of flow state
    
    func willSubmitGame() {
        assert(NSThread.isMainThread(), "Must be called on main")
        waitingOnGameResult = true
        updateState()
    }
    
    func didReceiveGameResult(newMatch: Connection?) {
        assert(NSThread.isMainThread(), "Must be called on main")
        waitingOnGameResult = false
        newMatchToShow = newMatch
        updateState()
    }
    
    func didShowNewMatch() {
        assert(NSThread.isMainThread(), "Must be called on main")
        newMatchToShow = nil
        updateState()
    }
    
    func refreshRandomDemoState() {
        // Check precondition for demo mode is satisfied
        if (loginComplete && canPlayNewGame && hasConnections) {
            demoState = [.NewMatch, .BoatSailed, .NewGame].randomElement()!
            newMatchToShow = (demoState == State.NewMatch) ? Connection.crabConnection() : nil
            updateState()
            Log.info("New random demo state = \(demoState)")
        }
    }
    
    // MARK: State Spec & Update
    
    private func stateOverride() -> State? {
        if let state = ms.meta.debugState {
            switch state {
            case .NewMatch:
                newMatchToShow = newMatchToShow ?? Connection.all().fetchFirst() as? Connection
                return newMatchToShow != nil ? state : nil
            default:
                return state
            }
        }
        // demo state handling
        if ms.meta.demoMode != true && demoState != nil {
            demoState = nil
        } else if ms.meta.demoMode == true && demoState == nil {
            refreshRandomDemoState()
        }
        return demoState
    }
    
    private func computeCurrentState() -> State {
        if let state = stateOverride() {
            Log.warn("Skipping regular state handling, returning override state \(state)")
            return state
        }
        if ms.meta.logVerboseState {
            Log.verbose([
                "Internal Flow State:\n",
                "ms.account \(ms.account)\n",
                "ms.loggingIn \(ms.loggingIn)\n",
                "metadata.ready \(ms.subscriptions.metadata.ready)\n",
                "settings.ready \(ms.subscriptions.settings.ready)\n",
                "currentUser.ready \(ms.subscriptions.currentUser.ready)\n",
                "candidates.ready \(ms.subscriptions.candidates.ready)\n",
                "connections.ready \(ms.subscriptions.connections.ready)\n",
                "ms.settings.vetted \(ms.settings.vetted)\n",
                "hasBeenWelcomed \(ms.meta.hasBeenWelcomed)\n",
                "candidateCount \(ms.collections.candidates.allDocuments?.count)\n",
                "waitingOnGameResult \(waitingOnGameResult)\n",
                "newMatchToShow \(newMatchToShow)\n"
            ].reduce("", +))
        }

        // Startup Flow
        if ms.account == nil {
            return .Signup
        } else if (error != nil) {
            return .Error
        } else if (!loginComplete) {
            return .Loading
        }
        // Onboarding Flow
        if ms.settings.vetted != true {
            return .Waitlist
        } else if ms.meta.hasBeenWelcomed != true {
            return .Welcome
        }
        // Core Flow
        if waitingOnGameResult {
            return .Loading
        } else if (newMatchToShow != nil) {
            return .NewMatch
        } else if (canPlayNewGame) {
            return .NewGame
        } else {
            return .BoatSailed
        }
    }
    
    private func updateState(function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        Log.debug("Update state called from \(file.lastPathComponent):\(function):\(line) mt=\(NSThread.isMainThread())")
        dispatch_async(dispatch_get_main_queue()) {
            let lastState = self.currentState
            self.currentState = self.computeCurrentState()
            if lastState != self.currentState {
                Log.info("New state changed to \(self.currentState)")
                self.stateChanged.sendNext(nil)
            }
        }
    }
    
    // MARK: Notification Handling
        
    func meteorDatabaseDidChange(notification: NSNotification) {
        if let changes = notification.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
            for key in changes.affectedDocumentKeys() {
                let name = (key as? METDocumentKey)?.collectionName
                if name == "candidates" || name == "metadata" {
                    Log.debug("Collection \(name) did change")
                    updateState()
                    return
                }
            }
        }
    }
    
    func meteorAccountDidChange(notification: NSNotification) {
        updateState()
    }
}

// MARK: - METDDPClientDelegate

extension FlowService : METDDPClientDelegate {
    
    // General state updates
    func client(client: METDDPClient!, reachabilityStatusDidChange reachable: Bool) {
        // TODO: We ought to handle much more than just network unreachable error
        if error?.match(.NetworkUnreachable) == true && reachable {
            error = nil
        } else if error == nil && !reachable {
            error = NSError(.NetworkUnreachable)
        }
        updateState()
    }
    
    func client(client: METDDPClient!, willLoginWithMethodName methodName: String!, parameters: [AnyObject]!) {
        updateState()
    }
    func client(client: METDDPClient!, didSucceedLoginToAccount account: METAccount!) {
        updateState()
        UD[.sMeteorUserId] = ms.userID
        Analytics.identifyUser(ms.userID!)
    }
    func client(client: METDDPClient!, didFailLoginWithWithError error: NSError!) {
        ms.logout()
        updateState()
    }
    func clientWillLogout(client: METDDPClient!) {
        updateState()
    }
    func clientDidLogout(client: METDDPClient!) {
        updateState()
    }
    func client(client: METDDPClient!, didReceiveReadyForSubscription subscription: METSubscription!) {
        assert(subscription.ready, "Subscription must be ready at this point")
        Log.debug("Subscription \(subscription.name)[\(subscription.identifier)] received ready=\(subscription.ready)")
        updateState()
    }
    func client(client: METDDPClient!, didReceiveError error: NSError!, forSubscription subscription: METSubscription!) {
        self.error = NSError(.SubscriptionError)
        updateState()
    }
    
    // Logging
    
    func client(client: METDDPClient!, willSendDDPMessage message: [NSObject : AnyObject]!) {
        Log.verbose("DDP > \(message)")
    }
    func client(client: METDDPClient!, didReceiveDDPMessage message: [NSObject : AnyObject]!) {
        Log.verbose("DDP < \(message)")
    }
}

// MARK: - State extensions for comparison and printing

extension FlowService.State : Printable {
    var description: String { return rawValue }
}

func ==(a: FlowService.State, b: FlowService.State) -> Bool {
    return a.rawValue == b.rawValue
}

func !=(a: FlowService.State, b: FlowService.State) -> Bool {
    return !(a == b)
}
