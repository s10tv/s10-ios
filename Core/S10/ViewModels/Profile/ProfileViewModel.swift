//
//  ProfileViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct ProfileViewModel {
    let subscription: MeteorSubscription
    
    init(meteor: MeteorService, user: User) {
        subscription = meteor.subscribe("activities", params: [user])
    }
}
