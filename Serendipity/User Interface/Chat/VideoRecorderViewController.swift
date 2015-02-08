//
//  VideoRecorderViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import GPUImage

protocol VideoRecorderDelegate {
    
    func didStartRecording(videoURL: NSURL)
    func didStopRecording()
}

@objc(VideoRecorderViewController)
class VideoRecorderViewController : UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: GPUImageView!
    var videoCamera : GPUImageVideoCamera?
    var filter : GPUImageFilter?
    var movieWriter : GPUImageMovieWriter?
    
    var delegate : VideoRecorderDelegate?
    
    var isRecording = false

    // saving video to device
    var videoPath : String?
    var videoURL : NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/video.m4v");
        videoURL = NSURL(fileURLWithPath: self.videoPath!)
        
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Front)
        if videoCamera != nil {
            videoCamera!.outputImageOrientation = .Portrait;
            setupMoviePlayer()
            videoCamera?.startCameraCapture()
        }
    }
    
    @IBAction func toggle(sender: UIButton!) {
        if (isRecording) {
            // stop recording
            movieWriter?.finishRecording()
            delegate?.didStopRecording()
            
            isRecording = false
            recordButton.setTitle("Start Recording", forState: UIControlState.Normal)
        } else {
            unlink(self.videoPath!) // remove any existing videos
            setupMoviePlayer()
            movieWriter?.startRecording()
            delegate?.didStartRecording(videoURL!);
            
            isRecording = true
            recordButton.setTitle("Stop Recording", forState: UIControlState.Normal)
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
