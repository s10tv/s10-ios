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
    
    func login(isNewUser: Bool) {
        branch.setIdentity(context.userId)
    }
    
    func logout() {
        branch.setIdentity(nil)
    }
    
    func reset() {
        branch.logout()
    }
}
