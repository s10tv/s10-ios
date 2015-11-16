//
//  AVKit.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import AVFoundation
import ReactiveCocoa
import AssetsLibrary
import SCRecorder
import Core

struct TSVideoSession {
    let recordSession: SCRecordSession
    let filter: SCFilter?
    let overlayImage: UIImage?
    
    func export() -> Future<NSURL, NSError> {
        return AVKit.exportVideo(recordSession, filter: filter, watermark: overlayImage)
    }
    
    func exportWithFirstFrame() -> Future<(NSURL, UIImage), NSError> {
        let videoURL = export()
        let firstFrame = videoURL.flatMap(AVKit.exportFirstFrame)
        return zip(videoURL.producer, firstFrame.producer).toFuture()
    }
}

class AVKit {
    static let defaultFilters = AVKit.allFilters()
    
    class func writeToSavedPhotosAlbum(url: NSURL, library: ALAssetsLibrary = ALAssetsLibrary()) -> Future<NSURL, NSError> {
        let promise = Promise<NSURL, NSError>()
        library.writeVideoAtPathToSavedPhotosAlbum(url) { assetURL, error in
            if let error = error {
                promise.failure(error)
            } else {
                promise.success(assetURL)
            }
        }
        return promise.future
    }
    
    class func exportVideo(session: SCRecordSession, filter: SCFilter? = nil, watermark: UIImage? = nil) -> Future<NSURL, NSError> {
        let promise = Promise<NSURL, NSError>()
        let exporter = SCAssetExportSession(asset: session.assetRepresentingSegments())
        exporter.videoConfiguration.filter = filter
        exporter.videoConfiguration.watermarkImage = watermark
        exporter.videoConfiguration.watermarkFrame = CGRectMake(0, 0, 480, 640) // TODO: Fix this hard-coded hack
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.outputUrl = session.outputUrl
        exporter.exportAsynchronouslyWithCompletionHandler {
            if let error = exporter.error {
                promise.failure(error)
            } else {
                promise.success(exporter.outputUrl!)
            }
        }
        return promise.future
    }
    
    class func exportFirstFrame(url: NSURL) -> Future<UIImage, NSError> {
        let generator = AVAssetImageGenerator(asset: AVURLAsset(URL: url, options: nil))
        generator.appliesPreferredTrackTransform = true
        return generator.generateImages([CMTimeMake(1, 60)]).toFuture()
    }
    
    class func allFilters() -> [SCFilter] {
        let emptyFilter = SCFilter.emptyFilter()
        emptyFilter.name = "#nofilter"
        return [
            emptyFilter,
            SCFilter(CIFilterName: "CIPhotoEffectProcess"),
            SCFilter(CIFilterName: "CIPhotoEffectChrome"),
            SCFilter(CIFilterName: "CIPhotoEffectMono"),
            SCFilter(CIFilterName: "CIPhotoEffectFade"),
            SCFilter(CIFilterName: "CIPhotoEffectInstant"),
            SCFilter(CIFilterName: "CIPhotoEffectNoir"),
            SCFilter(CIFilterName: "CIPhotoEffectTonal"),
            SCFilter(CIFilterName: "CIPhotoEffectTransfer"),
        ]
    }
}

extension AVAssetImageGenerator {
    
    func generateImages(times: [CMTime]) -> SignalProducer<UIImage, NSError> {
        return SignalProducer { sink, disposable in
            let times = times.map { NSValue(CMTime: $0) }
            var callbacksReceived = 0
            self.generateCGImagesAsynchronouslyForTimes(times) { requestTime, image, actualTime, result, error in
                switch result {
                case .Succeeded:
                    sendNext(sink, UIImage(CGImage: image!))
                case .Failed:
                    sendError(sink, error!)
                case .Cancelled:
                    sendInterrupted(sink)
                }
                callbacksReceived++
                if callbacksReceived == times.count {
                    sendCompleted(sink)
                }
            }
            disposable.addDisposable {
                self.cancelAllCGImageGeneration()
            }
        }
    }
}