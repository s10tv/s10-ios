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

// FlowService manages the different states user can be in taking into account everything

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
    
    private var loggingIn = false
    private var hasAccount = false
    // TODO: Implement tracking of vetting and accepted state
    private var vetted = true   // Vetted by us on server
    private var welcomed = true // Accepting approval and begun 1st game
    private var waitingOnGameResult = false // Waiting to hear back from server about recent game
    private(set) var newConnectionToShow : Connection?
    private(set) var candidateQueue : [Candidate]?
    
    private(set) var currentState = State.Loading
    
    private let stateChanged = RACSubject()
    private let nc = NSNotificationCenter.defaultCenter().proxy()
    
    override init() {
        super.init()
        // BUG ALERT: All these listeners create indefinite retain cycles because instance method are merely
        // curried functions and thus strongly references self
        // For the time being we'll ignore this problem for now because FlowService will never be deallocated
        nc.listen(METDDPClientDidChangeAccountNotification, block: _meteorAccountDidChange)
        nc.listen(.WillLoginToMeteor, block: _willLoginToMeteor)
        nc.listen(.DidSucceedLoginToMeteor, block: _didSucceedLoginToMeteor)
        nc.listen(.DidFailLoginToMeteor, block: _didFailLoginToMeteor)
        nc.listen(.DidSubmitGame, block: _didSubmitGame)
        nc.listen(.DidReceiveGameResult, block: _didReceiveGameResult)
        nc.listen(.CandidatesUpdated, block: _didUpdateCandidateQueue)

        updateState()
    }

    deinit {
        NC.removeObserver(self)
    }
    
    // MARK: Public API
    
    func stateUpdateSignal() -> RACSignal {
        var lastState : State?
        return stateChanged.startWith(nil).flattenMap { _ -> RACStream! in
            if lastState == self.currentState {
                return RACSignal.empty()
            }
            lastState = self.currentState
            return RACSignal.Return(nil)
        }.deliverOnMainThread()
    }
    
    func getStateMatching(criteria: (State) -> Bool, completion: (State) -> ()) {
        stateChanged.startWith(nil).deliverOnMainThread().takeUntilBlock { _ in
            return criteria(self.currentState)
        }.subscribeCompleted {
            completion(self.currentState)
        }
    }
    
    // MARK: State Management
    
    private func computeCurrentState() -> State {
        if loggingIn {
            return .Loading
        } else if !hasAccount {
            return .Signup
        } else if !vetted {
            return .Waitlist
        } else if !welcomed {
            return .Welcome
        } else if candidateQueue == nil {
            return .Loading
        } else if waitingOnGameResult {
            return .Loading
        } else if newConnectionToShow != nil {
            return .NewMatch
        } else if candidateQueue?.count >= 3 {
            return .NewGame
        } else {
            return .BoatSailed
        }
    }
    
    private func updateState() {
        currentState = computeCurrentState()
//        currentState = .Signup
        stateChanged.sendNext(nil)
        println("Current state updated to \(currentState)")
    }
    
    func clearNewConnectionToShow() {
        newConnectionToShow = nil
        updateState()
    }
    
    // MARK: - Notification handling
    
    func _meteorAccountDidChange(notification: NSNotification) {
        hasAccount = Core.meteor.hasAccount()
        updateState()
    }
    
    func _willLoginToMeteor(notification: NSNotification) {
        loggingIn = true
        updateState()
    }
    
    func _didSucceedLoginToMeteor(notification: NSNotification) {
        loggingIn = false
        hasAccount = true
        updateState()
    }

    func _didFailLoginToMeteor(notification: NSNotification) {
        loggingIn = false
        hasAccount = false
        updateState()
    }
    
    func _didUpdateCandidateQueue(notification: NSNotification) {
        candidateQueue = notification.object as? [Candidate]
        updateState()
    }
    
    func _didSubmitGame(notification: NSNotification) {
        waitingOnGameResult = true
        updateState()
    }
    
    func _didReceiveGameResult(notification: NSNotification) {
        // TODO: Should flow service be aware of the json data format server sends?
        // Or should this be handled by something that's closer to the network level
        if let yesId = notification.userInfo?["yes"] as? String {
            newConnectionToShow = Connection.findByDocumentID(yesId)
            assert(newConnectionToShow != nil, "Expect new connection to exist by now")
        }
        waitingOnGameResult = false
        updateState()
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

