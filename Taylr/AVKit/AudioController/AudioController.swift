//
//  AudioController.swift
//  S10
//
//  Created by Tony Xiao on 8/4/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import AVFoundation
import ReactiveCocoa
import Core

extension AVAudioSession {
    var audioCategory: AudioCategory {
        return AudioCategory.fromString(category)
    }
}

enum AudioCategory {
    case Ambient, SoloAmbient, Playback, Record, PlaybackAndRecord, AudioProcessing, MultiRoute
    
    var respectsMuteSwitch: Bool {
        switch self {
        case .Ambient, .SoloAmbient: return true
        default: return false
        }
    }
    
    var string: String {
        switch self {
        case .Ambient: return AVAudioSessionCategoryAmbient
        case .SoloAmbient: return AVAudioSessionCategorySoloAmbient
        case .Playback: return AVAudioSessionCategoryPlayback
        case .Record: return AVAudioSessionCategoryRecord
        case .PlaybackAndRecord: return AVAudioSessionCategoryPlayAndRecord
        case .AudioProcessing: return AVAudioSessionCategoryAudioProcessing
        case .MultiRoute: return AVAudioSessionCategoryMultiRoute
        }
    }
    static func fromString(category: String) -> AudioCategory {
        switch category {
        case AVAudioSessionCategoryAmbient: return .Ambient
        case AVAudioSessionCategorySoloAmbient: return .SoloAmbient
        case AVAudioSessionCategoryPlayback: return .Playback
        case AVAudioSessionCategoryRecord: return .Record
        case AVAudioSessionCategoryPlayAndRecord: return .PlaybackAndRecord
        case AVAudioSessionCategoryAudioProcessing: return .AudioProcessing
        case AVAudioSessionCategoryMultiRoute: return .MultiRoute
        default:
            println("WARNING: Unrecongized category provided \(category)")
            return .SoloAmbient
        }
    }
}

class AudioController {
    let audioSession: AVAudioSession  // Readonly
    let audioCategory: MutableProperty<AudioCategory> // Readonly
    let muteSwitchOn: MutableProperty<Bool> // Readonly
    let systemVolume: MutableProperty<Float> // Readonly
    let muted: PropertyOf<Bool>
    
    init() {
        audioSession = AVAudioSession.sharedInstance()
        audioCategory = MutableProperty(audioSession.audioCategory)
        muteSwitchOn = MutableProperty(false)
        systemVolume = MutableProperty(audioSession.outputVolume)
        systemVolume <~ NSNotificationCenter.defaultCenter().rac_notifications(
            name:"AVSystemController_SystemVolumeDidChangeNotification", object: nil) |> map {
            $0.userInfo?["AVSystemController_AudioVolumeNotificationParameter"]?.floatValue ?? 0
        }
        muted = PropertyOf(false, combineLatest(
            muteSwitchOn.producer,
            systemVolume.producer,
            audioCategory.producer
        ) |> map { muteSwitchOn, volume, category in
            if muteSwitchOn && category.respectsMuteSwitch {
                return true
            }
            return volume == 0
        })
    }
    
    func checkMuteSwitch() {
        let property = muteSwitchOn
        MuteChecker.check { muted in
            property.value = muted
        }
    }
    
    func setAudioCategory(category: AudioCategory) {
        if category != audioSession.audioCategory {
            audioSession.setCategory(category.string, error: nil)
            audioCategory.value = category
        }
    }
}
