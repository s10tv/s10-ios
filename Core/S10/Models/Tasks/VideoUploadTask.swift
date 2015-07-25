//
//  VideoUploadTask.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift

public class VideoUploadTask : Object {
    dynamic var id = "" // taskID
    dynamic var recipientId = ""
    dynamic var localURL = ""
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public class func findById(id: String, realm: Realm = Realm()) -> VideoDownloadTask? {
        let pred = NSPredicate(format: "id = %@", id)
        return realm.objects(VideoDownloadTask).filter(pred).first
    }
    
    public class func countUploads(recipientId: String, realm: Realm = Realm()) -> Int {
        return realm.objects(self).filter("recipientId = %@", recipientId).count
    }
    
    public class func countOfUploads(recipientId: String) -> SignalProducer<Int, NoError> {
        return Realm().notifier() |> map { _ in self.countUploads(recipientId) }
    }
}
