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

protocol EditorDelegate : NSObjectProtocol {
    func editor(editor: EditorViewController, didEditVideo outputURL:NSURL)
}

class EditorViewController : UIViewController {
    
    @IBOutlet weak var filterView: SCSwipeableFilterView!
    
    let player = SCPlayer()
    var recordSession: SCRecordSession!
    weak var delegate: EditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let emptyFilter = SCFilter.emptyFilter()
        emptyFilter.name = "#nofilter"
        filterView.filters = [
            emptyFilter,
            SCFilter(CIFilterName: "CIPhotoEffectNoir"),
            SCFilter(CIFilterName: "CIPhotoEffectChrome"),
            SCFilter(CIFilterName: "CIPhotoEffectInstant"),
            SCFilter(CIFilterName: "CIPhotoEffectTonal"),
            SCFilter(CIFilterName: "CIPhotoEffectFade"),
            SCFilter(CIFilterName: "CIPhotoEffectTransfer")
        ]
        filterView.contentMode = .ScaleAspectFill
        
        player.loopEnabled = true
        player.CIImageRenderer = filterView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        let segment = recordSession.segments.first as! SCRecordSessionSegment
//        player.setItemByUrl(segment.url)
        player.setItemByAsset(recordSession.assetRepresentingSegments())
        player.play()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        player.pause()
        player.setItem(nil)
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func finishEditing(sender: AnyObject) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let exporter = SCAssetExportSession(asset: recordSession.assetRepresentingSegments())
        exporter.videoConfiguration.filter = filterView.selectedFilter
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.outputUrl = recordSession.outputUrl
        exporter.exportAsynchronouslyWithCompletionHandler {
            self.delegate?.editor(self, didEditVideo: exporter.outputUrl)
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
}

