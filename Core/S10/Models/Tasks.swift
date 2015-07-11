//
//  Tasks.swift
//  S10
//
//  Created by Qiming Fang on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import RealmSwift

public class VideoUploadTaskEntry : Object {
    dynamic var id = ""
    dynamic var recipientId = ""
    dynamic var localURL = ""

    override public static func primaryKey() -> String? {
        return "id"
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
    
    public class func findById(realm: Realm, videoId: String) -> VideoDownloadTaskEntry? {
        let pred = NSPredicate(format: "videoId = %@", videoId)
        return realm.objects(VideoDownloadTaskEntry).filter(pred).first
    }
}