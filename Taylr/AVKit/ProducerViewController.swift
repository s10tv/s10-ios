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
    func producer(producer: ProducerViewController, didProduceVideo url: NSURL)
}

class ProducerViewController : UIViewController {
    
    var recorderVC: RecorderViewController!
    var editorVC: EditorViewController!
    var currentFilter: SCFilter?
    weak var producerDelegate: ProducerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recorderVC = makeViewController(.Recorder) as! RecorderViewController
        editorVC = makeViewController(.Editor) as! EditorViewController
        recorderVC.delegate = self
        editorVC.delegate = self
        
        addChildViewController(recorderVC)
        addChildViewController(editorVC)
        recorderVC.didMoveToParentViewController(self)
        editorVC.didMoveToParentViewController(self)
        showRecorder()
    }
    
    func showRecorder() {
        editorVC.view.removeFromSuperview()
        view.addSubview(recorderVC.view)
        recorderVC.view.makeEdgesEqualTo(view)
    }
    
    func showEditor() {
        recorderVC.view.removeFromSuperview()
        view.addSubview(editorVC.view)
        editorVC.view.makeEdgesEqualTo(view)
    }
}

extension ProducerViewController : RecorderDelegate {
    func recorderWillStartRecording(recorder: RecorderViewController) {
        producerDelegate?.producerWillStartRecording(self)
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
    
    func editor(editor: EditorViewController, didEditVideo outputURL: NSURL) {
        producerDelegate?.producer(self, didProduceVideo: outputURL)
        showRecorder()
    }
}
