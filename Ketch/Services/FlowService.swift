//
//  FlowService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/7/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import ReactiveCocoa
import Foundation

// FlowService manages the different states user can be in taking into account everything

class FlowService : NSObject {
    enum State {
        case Loading
        case Signup
        case Waitlist
        case Approval
        case BoatSailed
        case NewMatch(Connection)
        case NewGame(Candidate, Candidate, Candidate)
    }
    
    private var loggingIn = false
    
    // TODO: These are not true by default, update to sensible value
    private var signedUp = true
    private var vetted = true   // Vetted by us on server
    private var accepted = true // Accepting approval and begun 1st game
    private var waitingOnGameResult = false // Waiting to hear back from server about recent game
    private var newConnectionToShow : Connection?
    private var candidateQueue : [Candidate] = []
    
    private let stateChanged = RACReplaySubject(capacity: 0)
    private var currentState = State.Loading
    
    override init() {
        super.init()
        NC.addObserver(self, selector: "_didSubmitGame", name: .DidSubmitGame)
        NC.addObserver(self, selector: "_didReceiveGameResult:", name: .DidReceiveGameResult)
        NC.addObserver(self, selector: "_didUpdateCandidateQueue:", name: .CandidatesUpdated)
        updateState()
    }

    deinit {
        NC.removeObserver(self)
    }
    
    // MARK: Public API
    
    func getCurrentState() -> State {
        return currentState
    }
    
    func getStateMatching(criteria: (State) -> Bool, completion: (State) -> ()) {
        stateChanged.startWith(nil).deliverOnMainThread().takeUntilBlock { _ in
            return criteria(self.currentState)
        }.subscribeCompleted {
            completion(self.currentState)
        }
    }
    
    // MARK: State Management
    
    private  func computeCurrentState() -> State {
        if loggingIn {
            return .Loading
        } else if !signedUp {
            return .Signup
        } else if !vetted {
            return .Waitlist
        } else if !accepted {
            return .Approval
        } else if waitingOnGameResult {
            return .Loading
        } else if newConnectionToShow != nil {
            return .NewMatch(newConnectionToShow!)
        } else if candidateQueue.count >= 3 {
            return .NewGame(candidateQueue[0], candidateQueue[1], candidateQueue[2])
        } else {
            return .BoatSailed
        }
    }
    
    private func updateState() {
        currentState = computeCurrentState()
        stateChanged.sendNext(nil)
        println("Current state updated to \(currentState)")
    }
    
    // MARK: - Notification handling
    
    func _didSubmitGame() {
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
    
    func _didUpdateCandidateQueue(notification: NSNotification) {
        candidateQueue = notification.object as [Candidate]
        updateState()
    }
}

// MARK: - State extensions for comparison and printing

func ==(a: FlowService.State, b: FlowService.State) -> Bool {
    switch (a, b) {
    case (.Loading, .Loading): return true
    case (.Signup, .Signup): return true
    case (.Waitlist, .Waitlist): return true
    case (.Approval, .Approval): return true
    case (.BoatSailed, .BoatSailed): return true
    case let (.NewMatch(a), .NewMatch(b)):
        return a.documentID == b.documentID
    case let (.NewGame(a1, a2, a3), .NewGame(b1, b2, b3)):
        return [a1, a2, a3].map { $0.documentID } == [b1, b2, b3].map { $0.documentID }
    default:
        return false
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
        case .Approval: return "Approval"
        case .BoatSailed: return "BoatSailed"
        case .NewMatch(_): return "NewMatch"
        case .NewGame(_, _, _): return "NewGame"
        }
    }
}

