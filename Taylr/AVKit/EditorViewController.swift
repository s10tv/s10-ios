//
//  VideoEditorViewController.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import AVFoundation
import SCRecorder
import AssetsLibrary
import PKHUD

protocol EditorDelegate : NSObjectProtocol {
    func editorDidCancel(editor: EditorViewController)
    func editor(editor: EditorViewController, didEditVideo outputURL:NSURL)
}

class EditorViewController : UIViewController {
    
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
    
    func exportVideo(block: ((NSURL) -> Void)) {
        let exporter = SCAssetExportSession(asset: recordSession.assetRepresentingSegments())
        exporter.videoConfiguration.filter = filterView.selectedFilter
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.outputUrl = recordSession.outputUrl
        exporter.exportAsynchronouslyWithCompletionHandler {
            block(exporter.outputUrl!)
        }
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        delegate?.editorDidCancel(self)
    }

    @IBAction func finishEditing(sender: AnyObject) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        player.pause()
        PKHUD.showText("Sending")
        exportVideo { url in
            self.delegate?.editor(self, didEditVideo: url)
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
    
    @IBAction func saveToCameraRoll(sender: AnyObject) {
        exportVideo { url in
            PKHUD.showActivity(dimsBackground: true)
            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(url) { url, err in
                PKHUD.hide(animated: true)
                println("Finished writing \(url), \(err)")
            }
        }
    }
}

