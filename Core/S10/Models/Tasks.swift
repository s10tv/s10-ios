//
//  Tasks.swift
//  S10
//
//  Created by Qiming Fang on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift

public class VideoUploadTaskEntry : Object {
    dynamic var id = "" // taskID
    dynamic var recipientId = ""
    dynamic var localURL = ""

    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public class func findById(id: String, realm: Realm = Realm()) -> VideoDownloadTaskEntry? {
        let pred = NSPredicate(format: "id = %@", id)
        return realm.objects(VideoDownloadTaskEntry).filter(pred).first
    }
    
    public class func countUploads(recipientId: String, realm: Realm = Realm()) -> Int {
        return realm.objects(self).filter("recipientId = %@", recipientId).count
    }
    
    public class func countOfUploads(recipientId: String) -> SignalProducer<Int, NoError> {
        return Realm().notifier() |> map { _ in self.countUploads(recipientId) }
    }
}

public class VideoDownloadTaskEntry : Object {
    dynamic var videoId = ""
    dynamic var senderId = ""
    dynamic var remoteUrl = ""
    dynamic var resumeData = NSData()
    // Should be NSData?, workaround for issue https://github.com/realm/realm-cocoa/issues/628
    
    override public static func primaryKey() -> String? {
        return "videoId"
    }
    
    public class func findByVideoId(videoId: String, realm: Realm = Realm()) -> VideoDownloadTaskEntry? {
        let pred = NSPredicate(format: "videoId = %@", videoId)
        return realm.objects(VideoDownloadTaskEntry).filter(pred).first
    }
    
    public class func countDownloads(senderId: String, realm: Realm = Realm()) -> Int {
        return realm.objects(self).filter("senderId = %@", senderId).count
    }
    
    public class func countOfDownloads(senderId: String) -> SignalProducer<Int, NoError> {
        return Realm().notifier() |> map { _ in self.countDownloads(senderId) }
    }
}

public class InviteTaskEntry : Object {
    dynamic var taskId = ""
    dynamic var localVideoUrl = ""
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var emailOrPhone = ""
    
    public class func findByTaskId(taskId: String, realm: Realm = Realm()) -> InviteTaskEntry? {
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