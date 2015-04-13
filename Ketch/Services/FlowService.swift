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
    enum State {
        case Loading
        case Signup
        case Waitlist
        case Welcome
        case BoatSailed
        case NewMatch
        case NewGame
    }
    
    private let ms: MeteorService
    private let stateChanged = RACSubject()
    private var waitingOnGameResult = false // Waiting to hear back from server about recent game
    private(set) var newMatchToShow : Connection?
    private(set) var candidateQueue : [Candidate]?
    private(set) var currentState = State.Loading
    
    init(meteorService: MeteorService) {
        self.ms = meteorService
        super.init()
        meteorService.delegate = self
        listenForNotification(NSUserDefaultsDidChangeNotification, selector: "userDefaultsDidChange:")
        listenForNotification(METDatabaseDidChangeNotification, selector: "meteorDatabaseDidChange:")
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
    
    // MARK: State Spec & Update
    
    private func computeCurrentState() -> State {
        Log.verbose([
            "Internal Flow State:\n",
            "ms.account \(ms.account)\n",
            "ms.loggingIn \(ms.loggingIn)\n",
            "metadata.ready \(ms.subscriptions.metadata.ready)\n",
            "currentUser.ready \(ms.subscriptions.currentUser.ready)\n",
            "candidates.ready \(ms.subscriptions.candidates.ready)\n",
            "connections.ready \(ms.subscriptions.connections.ready)\n",
            "ms.meta.vetted \(ms.meta.vetted)\n",
            "hasBeenWelcomed \(UD[.bHasBeenWelcomed].bool)\n",
            "candidateCount \(ms.collections.candidates.allDocuments?.count)\n",
            "waitingOnGameResult \(waitingOnGameResult)\n",
            "newMatchToShow \(newMatchToShow)\n"
        ].reduce("", +))

        // Startup Flow
        if ms.account == nil {
            return .Signup
        } else if (ms.loggingIn ||
            !ms.subscriptions.metadata.ready ||
            !ms.subscriptions.currentUser.ready ||
            !ms.subscriptions.candidates.ready ||
            !ms.subscriptions.connections.ready) {
            // BUG ALERT: Prior to user login, metadata collection would get sent down without vetted
            // and then subscription would be considered ready. How can we solve it?
            return .Loading
        }
        // Onboarding Flow
        if ms.meta.vetted != true {
            return .Waitlist
        } else if UD[.bHasBeenWelcomed].bool != true {
            return .Welcome
        }
        // Core Flow
        if waitingOnGameResult {
            return .Loading
        } else if (newMatchToShow != nil) {
            return .NewMatch
        } else if (ms.collections.candidates.allDocuments?.count >= 3) {
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
    
    func userDefaultsDidChange(notification: NSNotification) {
        updateState()
    }
    
    func meteorDatabaseDidChange(notification: NSNotification) {
        if let changes = notification.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
            for key in changes.affectedDocumentKeys() {
                if (key as? METDocumentKey)?.collectionName == "candidates" {
                    updateState()
                    return
                }
            }
        }
    }
}

// MARK: - METDDPClientDelegate

extension FlowService : METDDPClientDelegate {
    
    // General state updates
    
    func client(client: METDDPClient!, willLoginWithMethodName methodName: String!, parameters: [AnyObject]!) {
        updateState()
    }
    func client(client: METDDPClient!, didSucceedLoginToAccount account: METAccount!) {
        updateState()
    }
    func client(client: METDDPClient!, didFailLoginWithWithError error: NSError!) {
        updateState()
    }
    func clientWillLogout(client: METDDPClient!) {
        updateState()
    }
    func clientDidLogout(client: METDDPClient!) {
        updateState()
    }
    func client(client: METDDPClient!, didReceiveReadyForSubscription subscription: METSubscription!) {
        updateState()
    }
    func client(client: METDDPClient!, didReceiveError error: NSError!, forSubscription subscription: METSubscription!) {
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

func ==(a: FlowService.State, b: FlowService.State) -> Bool {
    switch (a, b) {
    case (.Loading, .Loading): return true
    case (.Signup, .Signup): return true
    case (.Waitlist, .Waitlist): return true
    case (.Welcome, .Welcome): return true
    case (.BoatSailed, .BoatSailed): return true
    case (.NewMatch, .NewMatch): return true
    case (.NewGame, .NewGame): return true
    default: return false
    }
}

func !=(a: FlowService.State, b: FlowService.State) -> Bool {
    return !(a == b)
}

extension FlowService.State : Printable {
    var description: String {
        switch self {
        case .Loading: return "Loading"
        case .Signup: return "Signup"
        case .Waitlist: return "Waitlist"
        case .Welcome: return "Welcome"
        case .BoatSailed: return "BoatSailed"
        case .NewMatch: return "NewMatch"
        case .NewGame: return "NewGame"
        }
    }
}
