//
//  PhotoUploadOperation.swift
//  S10
//
//  Created by Tony Xiao on 7/3/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReactiveCocoa
import Alamofire

public enum PhotoTaskType : String {
    case ProfilePic = "PROFILE_PIC"
    case CoverPic = "COVER_PIC"
}

internal class PhotoUploadOperation : AsyncOperation {
    
    let meteor: MeteorService
    let image: UIImage
    let taskType: PhotoTaskType
    
    init(meteor: MeteorService, image: UIImage, taskType: PhotoTaskType) {
        self.meteor = meteor
        self.image = image
        self.taskType = taskType
    }
    
    override func run() {
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let taskId = NSUUID().UUIDString
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        meteor.startTask(taskId, type: taskType.rawValue, metadata: [
            "width" : width,
            "height": height
            ]).flattenMap {
            let url = JSON($0)["url"].string!
            let request = NSMutableURLRequest(URL: NSURL(string : url)!)
            request.HTTPMethod = "PUT"
            request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
            request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            return Alamofire.upload(request, data: imageData!).rac_statuscode()
        }.flattenMap {
            if let code = $0 as? Int where code >= 200 && code < 300 {
                return self.meteor.finishTask(taskId)
            }
            return RACSignal.error(NSError(domain: "Azure", code: $0 as! Int, userInfo: nil))
        }.subscribeError({
            self.finish(.Error($0))
        }, completed: {
            self.finish(.Success)
        })
    }
}
