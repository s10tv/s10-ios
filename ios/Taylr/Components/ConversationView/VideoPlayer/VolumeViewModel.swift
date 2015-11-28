//
//  VolumeViewModel.swift
//  S10
//
//  Created by Tony Xiao on 8/4/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct VolumeViewModel {
    static let normalIcon = UIImage(named: "ic-speaker")!
    static let mutedIcon = UIImage(named: "ic-speaker-muted")!
    
    private let audio: AudioController
    let icon: PropertyOf<UIImage?>
    let value: PropertyOf<Float>
    var alpha: CGFloat { return audio.muted.value ? 1 : 0.01 }
    
    init() {
        audio = AudioController.sharedController
        icon = audio.muted
           .map { $0 ? VolumeViewModel.mutedIcon : VolumeViewModel.normalIcon }
        value = PropertyOf(0, combineLatest(
            audio.muted.producer,
            audio.systemVolume.producer
        ).map { $0 ? 0 : $1 }.skipRepeats)
    }
    
    func toggleAudioCategory() {
        let category = audio.getAudioCategory()
        audio.setAudioCategory(category == .PlaybackAndRecord ? .SoloAmbient : .PlaybackAndRecord)
    }
}