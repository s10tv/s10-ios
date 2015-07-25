//
//  InviteTask.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift

// TODO: Do not store absolute path to local files in the database because they contain
// uuid of the sandbox which might sometimes change after application upgrade
public class InviteTask : Object {
    public dynamic var taskId = ""
    public dynamic var localVideoUrl = ""
    public dynamic var firstName = ""
    public dynamic var lastName = ""
    public dynamic var emailOrPhone = ""
    
    override public static func primaryKey() -> String? {
        return "taskId"
    }
    
    public class func findByTaskId(taskId: String, realm: Realm = Realm()) -> InviteTask? {
        let pred = NSPredicate(format: "taskId = %@", taskId)
        return realm.objects(self).filter(pred).first
    }
    
    public class func countInvites(realm: Realm = Realm()) -> Int {
        return realm.objects(self).count
    }
    
    public class func countOfInvites() -> SignalProducer<Int, NoError> {
        return Realm().notifier() |> map { _ in self.countInvites() }
    }
}