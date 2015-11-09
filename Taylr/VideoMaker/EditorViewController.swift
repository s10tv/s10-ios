//
//  VideoEditorViewController.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveCocoa
import SCRecorder
import PKHUD
import Core

protocol EditorDelegate : NSObjectProtocol {
    func editorDidCancel(editor: EditorViewController)
    func editor(editor: EditorViewController, didEditVideo video: TSVideoSession)
}

class EditorViewController : UIViewController {
    
    @IBOutlet weak var topLayoutHeight: NSLayoutConstraint!
    @IBOutlet weak var filterView: SCSwipeableFilterView!
    @IBOutlet weak var overlayView: TransparentView!
    @IBOutlet weak var captionField: UITextField!
    
    let player = SCPlayer()
    var recordSession: SCRecordSession!
    var recordSessionFilter: SCFilter?
    weak var delegate: EditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterView.filters = AVKit.defaultFilters
        filterView.contentMode = .ScaleAspectFill
        
        player.loopEnabled = true
        player.CIImageRenderer = filterView
        captionField.delegate = self
        captionField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        let segment = recordSession.segments.first as! SCRecordSessionSegment
//        player.setItemByUrl(segment.url)
        filterView.selectedFilter = recordSessionFilter // filterView.filters[2] as! SCFilter
        player.setItemByAsset(recordSession.assetRepresentingSegments())
        player.play()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        player.pause()
        player.setItem(nil)
    }
    
    // MARK: -
    func getVideoSession() -> TSVideoSession {
        UIGraphicsBeginImageContextWithOptions(overlayView.bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        overlayView.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return TSVideoSession(recordSession: recordSession, filter: filterView.selectedFilter, overlayImage: image)
    }
    
    // MARK: -
    
    @IBAction func didTapOnPlayer(sender: AnyObject) {
        player.isPlaying ? player.pause() : player.play()
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        delegate?.editorDidCancel(self)
    }

    @IBAction func finishEditing(sender: AnyObject) {
        player.pause()
        delegate?.editor(self, didEditVideo: getVideoSession())
    }
    
    @IBAction func saveToCameraRoll(sender: AnyObject) {
        let video = getVideoSession()
        PKHUD.showActivity(dimsBackground: true)
        video.export()
            .flatMap { AVKit.writeToSavedPhotosAlbum($0) }
            .observeOn(UIScheduler())
            .toFuture()
            .onSuccess { assetURL in
                PKHUD.hide(animated: true)
                print("Finished writing to assetURL \(assetURL)")
            }
    }
}

extension EditorViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidChange(textField: UITextField) {
        if textField.text?.length == 0 {
            textField.backgroundColor = UIColor.clearColor()
        } else {
            textField.backgroundColor = UIColor(white: 0, alpha: 0.5)
        }
    }
}

