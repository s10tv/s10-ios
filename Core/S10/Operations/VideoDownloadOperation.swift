//
//  VideoDownloadOperation.swift
//  S10
//
//  Created by Tony Xiao on 7/10/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift
import Alamofire

internal class VideoDownloadOperation : AsyncOperation {
    let videoCache = VideoCache.sharedInstance
    let alamo = Manager(sessionType: .Default)
    let tempURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString)
    let videoId: String
    let remoteURL: NSURL
    let resumeData: NSData? // TODO: Make internal after Xcode 7
    var request: Request?
    
    init(videoId: String, remoteURL: NSURL) {
        self.videoId = videoId
        self.remoteURL = remoteURL
        resumeData = nil
    }
    
    init(task: VideoDownloadTask) {
        videoId = task.videoId
        remoteURL = NSURL(string: task.remoteUrl)!
        resumeData = task.resumeData.length > 0 ? task.resumeData : nil
    }
    
    override func run() {
        Log.info("Start VideoDownload id=\(videoId)")
        // Make request
        let dest: (NSURL, NSURLResponse) -> NSURL = { _, _ in
            return self.tempURL
        }
        request = resumeData.map { alamo.download($0, destination: dest) }
                ?? alamo.download(.GET, remoteURL, destination: dest)
        
        // Handle request
        let future = request!.validate().responseData()
            .flatMap { (data: NSData?) -> Future<NSData?, NSError> in
                let error = self.videoCache.setVideo(self.videoId, fileURL: self.tempURL)
                return error.map { Future(error: $0) } ?? Future(value: data)
            }
            .onComplete { result in
                _ = try? NSFileManager().removeItemAtURL(self.tempURL)
                let realm = unsafeNewRealm()
                if let task = VideoDownloadTask.findByVideoId(self.videoId, realm: realm) {
                    _ = try? realm.write {
                        switch result {
                        case .Success:
                            realm.delete(task)
                        case .Failure(let error):
                            if let resumeData = error.userInfo[kAlamofireResumeData] as? NSData {
                                task.resumeData = resumeData
                                Log.debug("VideoDownload got resumeData length=\(resumeData.length)")
                            } else {
                                realm.delete(task)
                            }
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
                    self.finish(.Error(error))
                    Log.info("VideoDownload didFail id=\(self.videoId)")
                }
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        request?.cancel()
        Log.info("Cancel VideoDownload id=\(videoId)")
    }
}
