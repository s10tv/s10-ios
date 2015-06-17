//
//  MasterViewController.swift
//  Camera
//
//  Created by Tony Xiao on 6/16/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import UIKit
import SCRecorder

class RecorderViewController: UIViewController {
    
    var recorder: SCRecorder!
    var photo: UIImage?
    var recordSession: SCRecordSession?
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBAction func switchCameraMode(sender: AnyObject) {
    }
    
    @IBAction func switchFlashButton(sender: AnyObject) {
    }
    @IBOutlet weak var flashModeButton: UIButton!
    @IBAction func switchGhostMode(sender: AnyObject) {
    }
    @IBOutlet weak var ghostModeButton: UIButton!
    @IBOutlet weak var switchCameraModeButton: UIButton!
    @IBAction func reverseCamera(sender: AnyObject) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        recorder = SCRecorder()
        recorder.previewView = previewView

        // Set the AVCaptureSessionPreset for the underlying AVCaptureSession.
        recorder.captureSessionPreset = AVCaptureSessionPresetHigh;
        
        // Set the video device to use
        recorder.device = AVCaptureDevicePosition.Front
        
        // Set the maximum record duration
        recorder.maxRecordDuration = CMTimeMake(10, 1);
        var err: NSErrorPointer = nil
        if !recorder.prepare(err) {
            println(err)
        }
        recorder.startRunning()
        recorder.session = recordSession
        recordSession = SCRecordSession()
        recordSession?.fileType = AVFileTypeQuickTimeMovie

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recorder.previewViewFrameChanged()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
}