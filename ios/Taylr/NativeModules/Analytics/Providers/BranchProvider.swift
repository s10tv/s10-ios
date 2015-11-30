//
//  BranchProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/24/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Branch

public class BranchProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!
    
    let branch: Branch
    
    init(branchKey: String) {
        branch = Branch.getInstance(branchKey)
    }
    
    func launch(currentBuild: String, previousBuild: String?) {
        if let userId = context.userId {
            branch.setIdentity(userId)
        }
    }
    
    func login(isNewUser: Bool) {
        branch.setIdentity(context.userId)
    }
    
    func logout() {
        branch.logout()
        // Should we calso call resetUserSession() ?
    }
    
    func track(event: String, properties: [NSObject : AnyObject]?) {
        branch.userCompletedAction(event, withState: properties)
    }
    
}
