//
//  RecorderController.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder

protocol ProducerDelegate : NSObjectProtocol {
    func producerWillStartRecording(producer: ProducerViewController)
    func producerDidCancelRecording(producer: ProducerViewController)
    func producer(producer: ProducerViewController, didProduceVideo video: VideoSession, duration: NSTimeInterval)
}

class ProducerViewController : UIViewController {
    
    var recorderVC: RecorderViewController!
    var editorVC: EditorViewController!
    var currentFilter: SCFilter?
    weak var producerDelegate: ProducerDelegate?
    
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

extension ProducerViewController : RecorderDelegate {
    func recorderWillStartRecording(recorder: RecorderViewController) {
        producerDelegate?.producerWillStartRecording(self)
    }
    
    func recorderDidCancelRecording(recorder: RecorderViewController) {
        producerDelegate?.producerDidCancelRecording(self)
    }
    
    func recorder(recorder: RecorderViewController, didRecordSession session: SCRecordSession) {
        editorVC.recordSession = session
        currentFilter = recorder.previewView.selectedFilter
        editorVC.recordSessionFilter = currentFilter
        showEditor()
    }
}

extension ProducerViewController : EditorDelegate {
    func editorDidCancel(editor: EditorViewController) {
        currentFilter = editorVC.filterView.selectedFilter
        recorderVC.previewView.selectedFilter = currentFilter
        showRecorder()
        producerDelegate?.producerDidCancelRecording(self)
    }
    
    func editor(editor: EditorViewController, didEditVideo video: VideoSession) {
        producerDelegate?.producer(self, didProduceVideo: video, duration: editor.recordSession.duration.seconds)
        showRecorder()
    }
}
