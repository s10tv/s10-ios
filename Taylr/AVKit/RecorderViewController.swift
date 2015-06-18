//
//  RecorderViewController.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder

class RecorderViewController : BaseViewController {
    
    @IBOutlet weak var previewView: SCFilterSelectorView!
    
    let recorder = SCRecorder.sharedRecorder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recorder.captureSessionPreset = AVCaptureSessionPresetHigh
        recorder.device = .Front
        recorder.CIImageRenderer = previewView
        
        previewView.filters = [SCFilter.emptyFilter()]
        previewView.CIImage = CIImage(color: CIColor(red: 0, green: 0, blue: 0))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        recorder.startRunning()
    }
    
}