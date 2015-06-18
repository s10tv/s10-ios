//
//  MasterViewController.swift
//  Camera
//
//  Created by Tony Xiao on 6/16/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import UIKit
import SCRecorder
import Core

class TestRecorderViewController: UIViewController {
    
    var recorder: SCRecorder!
    var recordSession: SCRecordSession?
    
    @IBOutlet weak var filterView: SCSwipeableFilterView!

    override func viewDidLoad() {
        super.viewDidLoad()
        filterView.filters = [SCFilter.emptyFilter(),
                SCFilter(CIFilterName: "CIPhotoEffectInstant"),
        SCFilter(CIFilterName: "CIPhotoEffectChrome"),
        SCFilter(CIFilterName: "CIPhotoEffectTonal"),
        SCFilter(CIFilterName: "CIPhotoEffectFade")]
        filterView.transform = CGAffineTransformMakeScale(-1, 1)
        // Force EAGL context to load and thus preview to render
        filterView.CIImage = CIImage(color: CIColor(red: 0, green: 0, blue: 0))
        recorder = SCRecorder()
        recorder.CIImageRenderer = filterView

        // Set the AVCaptureSessionPreset for the underlying AVCaptureSession.
        recorder.captureSessionPreset = AVCaptureSessionPresetHigh;
        
        // Set the video device to use
        recorder.device = AVCaptureDevicePosition.Front
        
        recorder.startRunning()
        recorder.session = recordSession
        recordSession = SCRecordSession()
        recordSession?.fileType = AVFileTypeMPEG4
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recorder.previewViewFrameChanged()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
}