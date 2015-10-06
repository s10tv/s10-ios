//
//  VideoDownloadTask.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift

internal class VideoDownloadTask : Object {
    dynamic var videoId = ""
    dynamic var senderId = ""
    dynamic var connectionId = ""
    dynamic var remoteUrl = ""
    dynamic var resumeData = NSData()
    
    // Should be NSData?, workaround for issue https://github.com/realm/realm-cocoa/issues/628
    
    override static func primaryKey() -> String? {
        return "videoId"
    }
    
    class func findByVideoId(videoId: String, realm: Realm = unsafeNewRealm()) -> VideoDownloadTask? {
        let pred = NSPredicate(format: "videoId = %@", videoId)
        return realm.objects(VideoDownloadTask).filter(pred).first
    }
    
    class func countDownloads(conversationId: ConversationId, realm: Realm = unsafeNewRealm()) -> Int {
        let results = realm.objects(self)
        switch conversationId {
        case .ConnectionId(let connectionId):
            return results.filter("connectionId = %@", connectionId).count
        case .UserId(let userId):
            return results.filter("senderId = %@", userId).count
        }
    }
    
    class func countOfDownloads(conversationId: ConversationId) -> SignalProducer<Int, NoError> {
        return SignalProducer(value: countDownloads(conversationId))
            .concat(unsafeNewRealm().notifier().map { _ in self.countDownloads(conversationId) })
    }
}
