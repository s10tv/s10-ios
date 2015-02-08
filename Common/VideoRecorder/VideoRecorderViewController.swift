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
    var stillCamera : GPUImageStillCamera?
    
    var filter : GPUImageFilter?
    var singleFrameFilter : GPUImageFilter?
    var thumbnail : NSData?

    var movieWriter : GPUImageMovieWriter?
    weak var delegate : VideoRecorderDelegate?
    
    var isRecording = false

    // saving video to device
    var videoPath : String?
    var videoURL : NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/video.m4v");
        videoURL = NSURL(fileURLWithPath: self.videoPath!)

        // video camera. used for video capture.
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Front)
        if videoCamera != nil {
            videoCamera!.outputImageOrientation = .Portrait;
            setupMoviePlayer()
        }
        
        // still camera. used for thumbnail capture.
        stillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Front)
        if stillCamera != nil {
            singleFrameFilter = GPUImageBrightnessFilter()
            stillCamera?.outputImageOrientation = .Portrait
            stillCamera?.addTarget(singleFrameFilter)
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

            stillCamera?.startCameraCapture()
            stillCamera?.capturePhotoAsPNGProcessedUpToFilter(singleFrameFilter, withCompletionHandler: { data, error -> Void in
                self.thumbnail = data
                self.stillCamera?.stopCameraCapture()
                
                self.videoCamera?.startCameraCapture()
                self.movieWriter?.startRecording()
                self.isRecording = true
                self.recordButton.setTitle("Stop Recording", forState: UIControlState.Normal)
            })
        }
    }
    
    func setupMoviePlayer() {
        filter = GPUImageBrightnessFilter()
        filter?.addTarget(cameraView)
        
        movieWriter = GPUImageMovieWriter(movieURL: videoURL, size: CGSizeMake(480, 640))
        movieWriter?.shouldPassthroughAudio = true
        filter?.addTarget(movieWriter)
        
        videoCamera?.addTarget(filter)
    }
}
