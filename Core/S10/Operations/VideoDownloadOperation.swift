//
//  VideoDownloadOperation.swift
//  S10
//
//  Created by Tony Xiao on 7/10/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import BrightFutures
import Core

public class VideoDownloadOperation : AsyncOperation {
    let videoCache = VideoCache.sharedInstance
    let alamo = Manager(sessionType: .Default)
    let tempURL = NSURL(fileURLWithPath: NSTemporaryDirectory())!.URLByAppendingPathComponent(NSUUID().UUIDString)
    let videoId: String
    let senderId: String
    let remoteURL: NSURL
    public let resumeData: NSData? // TODO: Make internal after Xcode 7
    var request: Request?
    
    public init(videoId: String, senderId: String, remoteURL: NSURL) {
        self.videoId = videoId
        self.senderId = senderId
        self.remoteURL = remoteURL
        resumeData = nil
    }
    
    public init(task: VideoDownloadTask) {
        videoId = task.videoId
        senderId = task.senderId
        remoteURL = NSURL(string: task.remoteUrl)!
        resumeData = task.resumeData.length > 0 ? task.resumeData : nil
    }
    
    public override func run() {
        Log.info("Start VideoDownload id=\(videoId)")
        // Persist record
        let realm = Realm()
        realm.write {
            let task = VideoDownloadTask()
            task.videoId = self.videoId
            task.senderId = self.senderId
            task.remoteUrl = self.remoteURL.absoluteString!
            realm.add(task, update: true)
        }
        
        // Make request
        let dest: (NSURL, NSURLResponse) -> NSURL = { _, _ in
            return self.tempURL
        }
        request = resumeData.map { alamo.download($0, destination: dest) }
                ?? alamo.download(.GET, remoteURL, destination: dest)
        
        // Handle request
        let future = perform {
            request!.validate().responseData()
        }.flatMap { (data: NSData?) -> Future<NSData?, NSError> in
            let error = self.videoCache.setVideo(self.videoId, fileURL: self.tempURL)
            return error.map { Future.failed($0) } ?? Future.succeeded(data)
        }.andThen { result in
            NSFileManager().removeItemAtURL(self.tempURL, error: nil)
            let realm = Realm()
            if let task = VideoDownloadTask.findByVideoId(self.videoId, realm: realm) {
                realm.write {
                    switch result {
                    case .Success:
                        realm.delete(task)
                    case .Failure(let error):
                        task.resumeData = error.value.userInfo?[kAlamofireResumeData] as? NSData ?? NSData()
                        let desc = NSString(data:task.resumeData, encoding:NSUTF8StringEncoding) as! String
                        Log.debug("VideoDownload got resumeData \(desc)")
                    }
                }
            } else {
                Log.error("VideoDownloadOperation complete but unable to find task with videoId=\(self.videoId)")
            }
        }
        
        // Report result
        future.onComplete { result in
            if self.cancelled {
                self.finish(.Cancelled)
                Log.info("VideoDownload didCancel id=\(self.videoId)")
            } else {
                switch result {
                case .Success:
                    self.finish(.Success)
                    Log.info("VideoDownload didSucceed id=\(self.videoId)")
                case .Failure(let error):
                    self.finish(.Error(error.value))
                    Log.info("VideoDownload didFail id=\(self.videoId)")
                }
            }
        }
    }
    
    public override func cancel() {
        super.cancel()
        request?.cancel()
        Log.info("Cancel VideoDownload id=\(videoId)")
    }
}
