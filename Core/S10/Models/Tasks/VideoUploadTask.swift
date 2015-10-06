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
    dynamic var userId = ""
    dynamic var connectionId = ""
    dynamic var localVideoUrl = ""
    dynamic var duration: NSTimeInterval = 0
    dynamic var thumbnailData = NSData()
    dynamic var width = 0
    dynamic var height = 0
    
    // TODO: Add accessor for Recipient on VideoUploadTask
    
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
    
    class func countUploads(conversationId: RecipientId, realm: Realm = unsafeNewRealm()) -> Int {
        let results = realm.objects(self)
        switch conversationId {
        case .ConnectionId(let connectionId):
            return results.filter("connectionId = %@", connectionId).count
        case .UserId(let userId):
            return results.filter("userId = %@", userId).count
        }
    }
    
    class func countOfUploads(conversationId: RecipientId) -> SignalProducer<Int, NoError> {
        return SignalProducer(value: countUploads(conversationId))
            .concat(unsafeNewRealm().notifier().map { _ in self.countUploads(conversationId) })
    }
}
