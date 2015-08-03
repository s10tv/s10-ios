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
import Bond
import SCRecorder
import Core

class AVKit {
    static let defaultFilters = AVKit.allFilters()
    
    class func exportFirstFrame(url: NSURL) -> Future<UIImage, NSError> {
        let generator = AVAssetImageGenerator(asset: AVURLAsset(URL: url, options: nil))
        generator.appliesPreferredTrackTransform = true
        return generator.generateImages([CMTimeMake(1, 60)]) |> toFuture
    }
    
    class func allFilters() -> [SCFilter] {
        let emptyFilter = SCFilter.emptyFilter()
        emptyFilter.name = "#nofilter"
        return [
            SCFilter(CIFilterName: "CIPhotoEffectChrome"),
            SCFilter(CIFilterName: "CIPhotoEffectMono"),
            SCFilter(CIFilterName: "CIPhotoEffectFade"),
            SCFilter(CIFilterName: "CIPhotoEffectInstant"),
            SCFilter(CIFilterName: "CIPhotoEffectNoir"),
            SCFilter(CIFilterName: "CIPhotoEffectProcess"),
            SCFilter(CIFilterName: "CIPhotoEffectTonal"),
            SCFilter(CIFilterName: "CIPhotoEffectTransfer"),
            emptyFilter,
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
                    sendNext(sink, UIImage(CGImage: image)!)
                case .Failed:
                    sendError(sink, error)
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