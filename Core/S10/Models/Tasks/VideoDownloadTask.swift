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

public class VideoDownloadTask : Object {
    dynamic var videoId = ""
    dynamic var senderId = ""
    dynamic var remoteUrl = ""
    dynamic var resumeData = NSData()
    // Should be NSData?, workaround for issue https://github.com/realm/realm-cocoa/issues/628
    
    override public static func primaryKey() -> String? {
        return "videoId"
    }
    
    public class func findByVideoId(videoId: String, realm: Realm = Realm()) -> VideoDownloadTask? {
        let pred = NSPredicate(format: "videoId = %@", videoId)
        return realm.objects(VideoDownloadTask).filter(pred).first
    }
    
    public class func countDownloads(senderId: String, realm: Realm = Realm()) -> Int {
        return realm.objects(self).filter("senderId = %@", senderId).count
    }
    
    public class func countOfDownloads(senderId: String) -> SignalProducer<Int, NoError> {
        return SignalProducer(value: countDownloads(senderId))
            |> concat(Realm().notifier() |> map { _ in self.countDownloads(senderId) })
    }
}
