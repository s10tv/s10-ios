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
import AMPopTip

protocol RecorderDelegate : NSObjectProtocol {
    func recorderWillStartRecording(recorder: RecorderViewController)
    func recorder(recorder: RecorderViewController, didRecordSession session: SCRecordSession)
}

class RecorderViewController : UIViewController {
    
    @IBOutlet weak var previewView: SCSwipeableFilterView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var filterHint: UIView!
    let recordTip = AMPopTip()
    
    let ud = NSUserDefaults.standardUserDefaults()
    
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
        previewView.delegate = self
        syncPreviewTransform()
        
        previewView.selectFilterScrollView.directionalLockEnabled = true
        
        filterHint.hidden = ud.boolForKey("hideSwipeFilterHint")
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
    
    @IBAction func toggleTorch(sender: AnyObject) {
        recorder.flashMode = recorder.flashMode == .Off ? .Light : .Off
    }
    
    @IBAction func flipCamera(sender: AnyObject) {
        recorder.switchCaptureDevices()
    }
    
    func syncPreviewTransform() {
        torchButton.hidden = !recorder.deviceHasFlash
        if recorder.device == .Front {
            previewView.transform = CGAffineTransformMakeScale(-1, 1)
        } else {
            self.previewView.transform = CGAffineTransformIdentity
        }
    }
    
    // MARK: -
    
    @IBAction func handleRecordTap(sender: AnyObject) {
        recordTip.showText("Press and hold to record", direction: .Up, maxWidth: 135,
            inView: view, fromFrame: recordButton.frame, duration: 1.5)
    }
    
    @IBAction func handleRecordLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            delegate?.recorderWillStartRecording(self)
            recorder.record()
        } else if sender.state == .Ended {
            recorder.pause()
        }
    }
}

extension RecorderViewController : SCRecorderDelegate {
    func recorder(recorder: SCRecorder, didBeginSegmentInSession session: SCRecordSession, error: NSError?) {
        filterHint.hidden = true
        ud.setBool(true, forKey: "hideSwipeFilterHint")
    }
    
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

extension RecorderViewController : SCSwipeableFilterViewDelegate {
    func swipeableFilterView(swipeableFilterView: SCSwipeableFilterView, didScrollToFilter filter: SCFilter?) {
        filterHint.hidden = true
    }
}
