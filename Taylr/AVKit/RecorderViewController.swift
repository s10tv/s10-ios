//
//  RecorderViewController.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder
import AVFoundation

protocol RecorderDelegate : NSObjectProtocol {
    func recorderWillStartRecording(recorder: RecorderViewController)
    func recorder(recorder: RecorderViewController, didRecordSession session: SCRecordSession)
}

class RecorderViewController : UIViewController {
    
    @IBOutlet weak var previewView: SCSwipeableFilterView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var recordButton: UIButton!
    
    let recorder = SCRecorder.sharedRecorder()
    weak var delegate: RecorderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recorder.session = SCRecordSession()
        recorder.session!.fileType = AVFileTypeMPEG4
        recorder.captureSessionPreset = AVCaptureSessionPreset640x480 // SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
//        recorder.autoSetVideoOrientation = true
        recorder.device = .Front
        recorder.CIImageRenderer = previewView
        recorder.keepMirroringOnWrite = true
        recorder.maxRecordDuration = CMTimeMake(15, 1) // 15 seconds
        recorder.delegate = self

        previewView.filters = AVKit.defaultFilters
        previewView.whenTapped(numberOfTaps: 2) { [weak self] _ in
            self?.recorder.switchCaptureDevices()
            return
        }
        syncPreviewTransform()
        
        previewView.selectFilterScrollView.directionalLockEnabled = true

        recordButton.addGestureRecognizer(TouchDetector(target: self, action: "handleRecordButtonTouch:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Start new recording
        // HACK ALERT: Force previewView to generate a GL context to draw on. 

        previewView.CIImage = CIImage(color: CIColor(red: 0, green: 0, blue: 0))
        recorder.session!.cancelSession(nil)
        progressView.progress = 0
        recorder.startRunning()
    }
    
    @IBAction func flipCamera(sender: AnyObject) {
        recorder.switchCaptureDevices()
    }
    
    func syncPreviewTransform() {
        if recorder.device == .Front {
            self.previewView.transform = CGAffineTransformMakeScale(-1, 1)
        } else {
            self.previewView.transform = CGAffineTransformIdentity
        }
    }
    
    // MARK: -
    
    func handleRecordButtonTouch(touchDetector: TouchDetector) {
        if touchDetector.state == .Began {
            recorder.record()
        } else if touchDetector.state == .Ended {
            recorder.pause()
        }
    }
}

extension RecorderViewController : SCRecorderDelegate {
    func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        syncPreviewTransform()
    }
    
    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession session: SCRecordSession) {
        progressView.progress = Float(recorder.ratioRecorded)
    }
    
    func recorder(recorder: SCRecorder, didAppendAudioSampleBufferInSession session: SCRecordSession) {
        progressView.progress = Float(recorder.ratioRecorded)
    }
    
    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession session: SCRecordSession, error: NSError?) {
        delegate?.recorder(self, didRecordSession: session)
    }
}