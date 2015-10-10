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
    let azure: AzureClient
    
    init(meteor: MeteorService, image: UIImage, taskType: PhotoTaskType) {
        self.meteor = meteor
        self.image = image
        self.taskType = taskType
        self.azure = AzureClient()
    }
    
    override func run() {
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let taskId = NSUUID().UUIDString
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        meteor.startTask(taskId, type: taskType.rawValue, metadata: [
            "width" : width,
            "height": height
        ]).flatMap { res -> Future<NSData?, NSError> in
            let url = NSURL(string: JSON(res!)["url"].string!)!
            return self.azure.put(url, data: imageData!, contentType: "image/jpeg")
        }.flatMap { _ in
            return self.meteor.finishTask(taskId)
        }.onFailure {
            self.finish(.Error($0))
        }.onSuccess {
            self.finish(.Success)
        }
    }
}
