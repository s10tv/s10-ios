//
//  LayerHelpers.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit

extension LYRConversation {
    // TODO: currentUserId should probably not be nil?
    func recipient(context: NSManagedObjectContext, currentUserId: String?) -> User? {
        let others = participants.filter { $0 != currentUserId }
        if let userId = others.first as? String {
            return context.existingObjectInCollection("users", documentID: userId) as? User
        }
        return nil
    }
}