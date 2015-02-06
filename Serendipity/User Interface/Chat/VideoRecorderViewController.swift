//
//  VideoRecorderViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import GPUImage

@objc(VideoRecorderViewController)
class VideoRecorderViewController : UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: GPUImageView!
    var videoCamera : GPUImageVideoCamera?
    var filter : GPUImageFilter?
    var movieWriter : GPUImageMovieWriter?
    
    var isRecording = false

    // saving video to device
    let pathToVideo = NSHomeDirectory().stringByAppendingPathComponent("Documents/video.m4v")
    let azureClient = AzureClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        if videoCamera != nil {
            videoCamera!.outputImageOrientation = .Portrait;
            
            filter = GPUImageBrightnessFilter()
            filter?.addTarget(cameraView)
            
            // set up recording mechanisms
            let videoUrl = NSURL(fileURLWithPath: pathToVideo)
            movieWriter = GPUImageMovieWriter(movieURL: videoUrl, size: CGSizeMake(480, 640))
            movieWriter?.shouldPassthroughAudio = true
            filter?.addTarget(movieWriter)
            
            videoCamera?.addTarget(filter)
            videoCamera?.startCameraCapture()
        }
    }
    
    @IBAction func toggle(sender: UIButton!) {
        if (isRecording) {
            // stop recording
            movieWriter?.finishRecording()
            recordButton.setTitle("Start Recording", forState: UIControlState.Normal)
            
            // send to azure
            azureClient.uploadVideo(pathToVideo, { blobid, err -> Void in
                if let fullError = err {
                    println("Error in video submission: %s", fullError.localizedDescription);
                    return
                }
                
                if let azureBlobId = blobid {
                    println("Message sent to %s", azureBlobId)
                }
            })
        } else {
            unlink(pathToVideo) // remove any existing videos
            movieWriter?.startRecording()
            recordButton.setTitle("Stop Recording", forState: UIControlState.Normal)
            isRecording = true
        }
    }
}
