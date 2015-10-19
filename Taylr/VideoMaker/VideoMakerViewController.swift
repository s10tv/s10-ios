//
//  VideoMakerViewController.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder

protocol VideoMakerDelegate : NSObjectProtocol {
    func videoMakerWillStartRecording(videoMaker: VideoMakerViewController)
    func videoMakerDidCancelRecording(videoMaker: VideoMakerViewController)
    func videoMaker(videoMaker: VideoMakerViewController, didProduceVideo video: VideoSession, duration: NSTimeInterval)
}

class VideoMakerViewController : UIViewController {
    
    var recorderVC: RecorderViewController!
    var editorVC: EditorViewController!
    var currentFilter: SCFilter?
    weak var producerDelegate: VideoMakerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sb = UIStoryboard(name: "VideoMaker", bundle: nil)
        recorderVC = sb.instantiateViewControllerWithIdentifier("Recorder") as! RecorderViewController
        editorVC = sb.instantiateViewControllerWithIdentifier("Editor") as! EditorViewController
        recorderVC.delegate = self
        editorVC.delegate = self
        
        addChildViewController(recorderVC)
        addChildViewController(editorVC)
        recorderVC.didMoveToParentViewController(self)
        editorVC.didMoveToParentViewController(self)
        showRecorder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: -
    
    func showRecorder() {
        editorVC.view.removeFromSuperview()
        view.insertSubview(recorderVC.view, atIndex: 0)
        recorderVC.view.makeEdgesEqualTo(view)
    }
    
    func showEditor() {
        recorderVC.view.removeFromSuperview()
        view.insertSubview(editorVC.view, atIndex: 0)
        editorVC.view.makeEdgesEqualTo(view)
    }
    
    @IBAction func didTapClose(sender: AnyObject) {
        dismissViewController(animated: true)
    }
}

extension VideoMakerViewController : RecorderDelegate {
    func recorderWillStartRecording(recorder: RecorderViewController) {
        producerDelegate?.videoMakerWillStartRecording(self)
    }
    
    func recorderDidCancelRecording(recorder: RecorderViewController) {
        producerDelegate?.videoMakerDidCancelRecording(self)
    }
    
    func recorder(recorder: RecorderViewController, didRecordSession session: SCRecordSession) {
        editorVC.recordSession = session
        currentFilter = recorder.previewView.selectedFilter
        editorVC.recordSessionFilter = currentFilter
        showEditor()
    }
}

extension VideoMakerViewController : EditorDelegate {
    func editorDidCancel(editor: EditorViewController) {
        currentFilter = editorVC.filterView.selectedFilter
        recorderVC.previewView.selectedFilter = currentFilter
        showRecorder()
        producerDelegate?.videoMakerDidCancelRecording(self)
    }
    
    func editor(editor: EditorViewController, didEditVideo video: VideoSession) {
        producerDelegate?.videoMaker(self, didProduceVideo: video, duration: editor.recordSession.duration.seconds)
        showRecorder()
    }
}
