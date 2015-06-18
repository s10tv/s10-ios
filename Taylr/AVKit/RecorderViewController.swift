//
//  RecorderViewController.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder

protocol RecorderDelegate : NSObjectProtocol {
    func recorder(recorder: RecorderViewController, didRecordSession session: SCRecordSession)
}

class RecorderViewController : BaseViewController {
    
    @IBOutlet weak var previewView: SCFilterSelectorView!
    @IBOutlet weak var recordButton: UIButton!
    
    let recorder = SCRecorder.sharedRecorder()
    weak var delegate: RecorderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recorder.session = SCRecordSession()
        recorder.session.fileType = AVFileTypeMPEG4
        recorder.captureSessionPreset = AVCaptureSessionPresetHigh
        recorder.device = .Front
        recorder.CIImageRenderer = previewView
        recorder.keepMirroringOnWrite = true

        previewView.transform = CGAffineTransformMakeScale(-1, 1)
        previewView.filters = [SCFilter.emptyFilter()]
        previewView.CIImage = CIImage(color: CIColor(red: 0, green: 0, blue: 0))
        previewView.whenTapped(numberOfTaps: 2) { _ in
            self.recorder.switchCaptureDevices()
        }

        recordButton.addGestureRecognizer(TouchDetector(target: self, action: "handleRecordButtonTouch:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Start new recording
        recorder.session.cancelSession(nil)
        recorder.startRunning()
    }
    
    @IBAction func flipCamera(sender: AnyObject) {
        recorder.switchCaptureDevices()
    }
    
    // MARK: -
    
    func handleRecordButtonTouch(touchDetector: TouchDetector) {
        if touchDetector.state == .Began {
            recorder.record()
        } else if touchDetector.state == .Ended {
            recorder.pause {
                delegate?.recorder(self, didRecordSession: recorder.session)
            }
        }
    }
}