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

internal class VideoUploadTask : Object {
    dynamic var id = "" // taskID
    dynamic var recipientId = ""
    dynamic var localURL = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func findById(id: String, realm: Realm = Realm()) -> VideoDownloadTask? {
        let pred = NSPredicate(format: "id = %@", id)
        return realm.objects(VideoDownloadTask).filter(pred).first
    }
    
    class func countUploads(recipientId: String, realm: Realm = Realm()) -> Int {
        return realm.objects(self).filter("recipientId = %@", recipientId).count
    }
    
    class func countOfUploads(recipientId: String) -> SignalProducer<Int, NoError> {
        return SignalProducer(value: countUploads(recipientId))
            |> concat(Realm().notifier() |> map { _ in self.countUploads(recipientId) })
    }
}
