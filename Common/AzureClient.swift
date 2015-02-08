//
//  AzureClient.swift
//  Serendipity
//
//  Created by Qiming Fang on 2/5/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Meteor

let AzureClient = AzureClientImpl()

// TODO(generate server URL with meteor)
class AzureClientImpl {
    
    private var meteor : METDDPClient! = nil
    
    func startWithMeteor(meteor: METDDPClient) {
        self.meteor = meteor
    }
    
    private func getSasURL(userId: String, extensionId: String, callback: ((String?, String?) -> Void)) {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "https://s10mobile.azure-mobile.net/api/uploadvideosas")!)
        urlRequest.HTTPMethod = "GET"
        urlRequest.addValue("NeHOImEPLUWXFdRmGmTWjRzoEbElSF33", forHTTPHeaderField: "X-ZUMO-APPLICATION")
        urlRequest.addValue(extensionId, forHTTPHeaderField: "extensionid")
        urlRequest.addValue(userId, forHTTPHeaderField: "userid")
        Alamofire.request(urlRequest).responseJSON {(_, _, data, error) in
            if let jsonData = data as? NSDictionary {
                let json = JSON(jsonData)
                return callback(json["sasUrl"].string, json["blobid"].string)
            }
            
            if (error != nil) {
                println(error);
            }
            
            return callback(nil, nil)
        }
    }
    
    func uploadToAzure(data : NSData, userId: String, extensionId: String,
        callback: ((String?, NSError?) -> Void)) {
        getSasURL (userId, extensionId: extensionId, { url, blobid in
            if let sasUrl = url {
                let urlRequest = NSMutableURLRequest(URL: NSURL(string: sasUrl)!)
                urlRequest.addValue("2012-02-12", forHTTPHeaderField: "x-ms-version")
                urlRequest.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
                Alamofire.upload(Method.PUT, urlRequest, data)
                    .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        print(".")
                    }
                    .responseJSON {(request, response, data, error) in
                        return callback(blobid, error)
                    }
            }
        })
    }
    
    func uploadVideoToAzure(videoPath : NSURL, userId: String,
        callback: (String?, NSError?) -> Void) {
            // uplaod the video
            let videoData = NSData(contentsOfURL: videoPath)!
            uploadToAzure(videoData, userId: userId, extensionId: "m4v", callback)
    }
    
    func sendMessage(videoPath : NSURL, thumbnail: NSData, recipientId: String,
        callback: ((String?, String?, AnyObject!, NSError?) -> Void)) {

            // TODO(qimingfang): fix hack of using this as base URL always.
            let rootURL: String = "https://s10.blob.core.windows.net/s10-prod/"
            
            // upload the thumbnail first
            self.uploadToAzure(thumbnail, userId: recipientId, extensionId: "png", { thumbBlob, thumbError in
                
                // then upload the video
                self.uploadVideoToAzure(videoPath, userId: recipientId, { videoBlob, videoError in
                    
                    let azureThumbnailPath = rootURL + thumbBlob!
                    let azureVideoPath = rootURL + videoBlob!
                    
                    // notify meteor that a new message has been sent.
                    self.meteor.callMethodWithName("sendMessage",
                        parameters: [recipientId, azureThumbnailPath, azureVideoPath], {
                            result, error -> Void in
                            return callback(azureThumbnailPath, azureVideoPath, result, error);
                    })
                    
                })
                
            })
    }
}