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
    dynamic var duration: NSTimeInterval = 0
    
    var localVideo: Video {
        var video = Video(NSURL(localURL))
        video.duration = duration
        return video
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func findById(id: String, realm: Realm = unsafeNewRealm()) -> VideoDownloadTask? {
        let pred = NSPredicate(format: "id = %@", id)
        return realm.objects(VideoDownloadTask).filter(pred).first
    }
    
    class func countUploads(recipientId: String, realm: Realm = unsafeNewRealm()) -> Int {
        return realm.objects(self).filter("recipientId = %@", recipientId).count
    }
    
    class func countOfUploads(recipientId: String) -> SignalProducer<Int, NoError> {
        return SignalProducer(value: countUploads(recipientId))
            .concat(unsafeNewRealm().notifier().map { _ in self.countUploads(recipientId) })
    }
}
