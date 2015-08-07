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
    func recorderDidCancelRecording(recorder: RecorderViewController)
    func recorder(recorder: RecorderViewController, didRecordSession session: SCRecordSession)
}

class RecorderViewController : UIViewController {
    @IBOutlet weak var topLayoutHeight: NSLayoutConstraint!
    @IBOutlet weak var previewView: SCSwipeableFilterView!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var filterHint: UIView!
    @IBOutlet var recordTapGesture: UITapGestureRecognizer!
    var filterPanGesture: UIPanGestureRecognizer {
        return previewView.selectFilterScrollView.panGestureRecognizer
    }
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
        recorder.maxRecordDuration = CMTimeMake(90, 1) // 90 seconds
        recorder.delegate = self

        previewView.filters = AVKit.defaultFilters
        previewView.selectedFilter = AVKit.defaultFilters.first // Force set it else doesn't seem to register
        previewView.whenTapped(numberOfTaps: 2) { [weak self] _ in
            self?.recorder.switchCaptureDevices()
            return
        }
        previewView.delegate = self
        syncPreviewTransform()

        previewView.selectFilterScrollView.directionalLockEnabled = true

        filterHint.hidden = ud.boolForKey("hideSwipeFilterHint")

        let touchDetector = TouchDetector(target: self, action: "handleRecordTouch:")
        recordTapGesture.delegate = self
        recordButton.addGestureRecognizer(touchDetector)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Start new recording
        // HACK ALERT: Force previewView to generate a GL context to draw on.
        previewView.CIImage = CIImage(color: CIColor(red: 0, green: 0, blue: 0))

        recorder.startRunning()
        restartSession()
        // Fix panning on screen edge pan to get back
        if let popGesture = navigationController?.interactivePopGestureRecognizer {
            popGesture.delegate = self
            filterPanGesture.requireGestureRecognizerToFail(popGesture)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer.delegate = nil
    }

    func restartSession() {
        recordButton.progress = 0
        recorder.session!.cancelSession(nil)
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

    @IBAction func handleRecordTouch(sender: TouchDetector) {
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
        recordButton.progress = Float(recorder.ratioRecorded)
    }

    func recorder(recorder: SCRecorder, didAppendAudioSampleBufferInSession session: SCRecordSession) {
        recordButton.progress = Float(recorder.ratioRecorded)
    }

    func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession session: SCRecordSession, error: NSError?) {
        // Ignore super short videos less than 1s
        if recorder.session!.duration.seconds < 1 {
            restartSession()
            delegate?.recorderDidCancelRecording(self)
        } else {
            delegate?.recorder(self, didRecordSession: session)
        }
    }
}

extension RecorderViewController : SCSwipeableFilterViewDelegate {
    func swipeableFilterView(swipeableFilterView: SCSwipeableFilterView, didScrollToFilter filter: SCFilter?) {
        filterHint.hidden = true
    }
}

extension RecorderViewController : UIGestureRecognizerDelegate {
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer {
            return otherGestureRecognizer is UIPanGestureRecognizer
        }
        if gestureRecognizer is UITapGestureRecognizer {
            return otherGestureRecognizer is TouchDetector
        }
        return false
    }
}
