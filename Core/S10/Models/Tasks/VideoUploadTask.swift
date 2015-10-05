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
    dynamic var taskId = ""
    dynamic var recipientId = ""
    dynamic var connectionId = ""
    dynamic var localVideoUrl = ""
    dynamic var duration: NSTimeInterval = 0
    dynamic var thumbnailData = NSData()
    dynamic var width = 0
    dynamic var height = 0
    
    var localVideo: Video {
        var video = Video(NSURL(localVideoUrl))
        video.duration = duration
        return video
    }
    
    override static func primaryKey() -> String? {
        return "taskId"
    }
    
    class func findByTaskId(id: String, realm: Realm = unsafeNewRealm()) -> VideoUploadTask? {
        let pred = NSPredicate(format: "taskId = %@", id)
        return realm.objects(VideoUploadTask).filter(pred).first
    }
    
    class func countUploads(recipientId: String, realm: Realm = unsafeNewRealm()) -> Int {
        return realm.objects(self).filter("recipientId = %@", recipientId).count
    }
    
    class func countOfUploads(recipientId: String) -> SignalProducer<Int, NoError> {
        return SignalProducer(value: countUploads(recipientId))
            .concat(unsafeNewRealm().notifier().map { _ in self.countUploads(recipientId) })
    }
}
