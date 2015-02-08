//
//  VideoRecorderViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import GPUImage

protocol VideoRecorderDelegate : class {
    
    // thumbnail is PNG format.
    func didStopRecording(videoURL : NSURL, thumbnail : NSData)
}

@objc(VideoRecorderViewController)
class VideoRecorderViewController : UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: GPUImageView!
    
    var videoCamera : GPUImageVideoCamera?
    var filter : GPUImageFilter?
    var movieWriter : GPUImageMovieWriter?
    weak var delegate : VideoRecorderDelegate?
    
    // keeps track of whether recording is happening. for the UI.
    var isRecording = false

    // saving video to device
    var videoPath : String?
    var videoURL : NSURL?
    var thumbnail : NSData?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/video.m4v");
        videoURL = NSURL(fileURLWithPath: self.videoPath!)

        // video camera. used for video capture.
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Front)
        if videoCamera != nil {
            videoCamera!.outputImageOrientation = .Portrait;
            filter = GPUImageBrightnessFilter()
            setupMoviePlayer()
            self.filter?.addTarget(self.cameraView)
            self.videoCamera?.startCameraCapture()
        }
    }
    
    @IBAction func toggle(sender: UIButton!) {
        if (isRecording) {
            // stop recording
            movieWriter?.finishRecording()
            
            delegate?.didStopRecording(videoURL!, thumbnail: thumbnail!)
            
            isRecording = false
            recordButton.setTitle("Start Recording", forState: UIControlState.Normal)
        } else {
            unlink(self.videoPath!) // remove any existing videos
            setupMoviePlayer()

            // capture thumbnail.
            self.filter?.useNextFrameForImageCapture()
            let retainedImage = self.filter?.newCGImageFromCurrentlyProcessedOutput()
            let image = retainedImage?.takeRetainedValue();
            let uiimage = UIImage(CGImage: image)
            self.thumbnail = UIImagePNGRepresentation(uiimage)
            
            // begin capturing video.
            self.movieWriter?.startRecording()
            self.isRecording = true
            self.recordButton.setTitle("Stop Recording", forState: UIControlState.Normal)
        }
    }
    
    func setupMoviePlayer() {
        movieWriter = GPUImageMovieWriter(movieURL: videoURL, size: CGSizeMake(480, 640))
        movieWriter?.shouldPassthroughAudio = true
        filter?.addTarget(movieWriter)
        
        videoCamera?.addTarget(filter)
        videoCamera?.audioEncodingTarget = movieWriter
    }
}
