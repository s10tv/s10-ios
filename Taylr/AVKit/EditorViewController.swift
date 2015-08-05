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
    func editor(editor: EditorViewController, didEditVideo video: VideoSession)
}

class EditorViewController : UIViewController {
    
    @IBOutlet weak var topLayoutHeight: NSLayoutConstraint!
    @IBOutlet weak var filterView: SCSwipeableFilterView!
    
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
    
    @IBAction func didTapOnPlayer(sender: AnyObject) {
        player.isPlaying ? player.pause() : player.play()
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        delegate?.editorDidCancel(self)
    }

    @IBAction func finishEditing(sender: AnyObject) {
        player.pause()
        let video = VideoSession(recordSession: recordSession, filter: filterView.selectedFilter)
        delegate?.editor(self, didEditVideo: video)
    }
    
    @IBAction func saveToCameraRoll(sender: AnyObject) {
        PKHUD.showActivity(dimsBackground: true)
        AVKit.exportVideo(recordSession, filter: filterView.selectedFilter)
            |> flatMap { AVKit.writeToSavedPhotosAlbum($0) }
            |> observeOn(UIScheduler())
            |> onSuccess { assetURL in
                PKHUD.hide(animated: true)
                println("Finished writing to assetURL \(assetURL)")
            }
    }
}

