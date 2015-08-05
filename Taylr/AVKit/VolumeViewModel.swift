//
//  VolumeViewModel.swift
//  S10
//
//  Created by Tony Xiao on 8/4/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core

struct VolumeViewModel {
    static let normalIcon = UIImage(named: "ic-speaker")!
    static let mutedIcon = UIImage(named: "ic-speaker-muted")!
    
    private let audio: AudioController
    let icon: PropertyOf<UIImage?>
    let value: PropertyOf<Float>
    var alpha: CGFloat { return audio.muted.value ? 1 : 0.01 }
    
    init() {
        audio = AudioController()
        icon = audio.muted
            |> map { $0 ? VolumeViewModel.mutedIcon : VolumeViewModel.normalIcon }
        value = PropertyOf(0, combineLatest(
            audio.muted.producer,
            audio.systemVolume.producer
        ) |> map { $0 ? 0 : $1 })
        
        // Whenever user presses volume button we'll switch to an active audio category
        // so that there's sound
        audio.systemVolume.producer
            |> skip(1)
            |> start(next: { [weak audio] _ in
                audio?.setAudioCategory(.PlaybackAndRecord)
            })
    }
    
    func checkMuteSwitch() {
        audio.checkMuteSwitch()
    }
    
    func toggleAudioCategory() {
        let category = audio.audioSession.audioCategory
        audio.setAudioCategory(category == .PlaybackAndRecord ? .SoloAmbient : .PlaybackAndRecord)
    }
}