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
            print("WARNING: Unrecongized category provided \(category)")
            return .SoloAmbient
        }
    }
}

class AudioController {
    private let muteChecker = MuteChecker()
    private let audioSession: AVAudioSession
    private let audioCategory: MutableProperty<AudioCategory>
    private let muteSwitchOn: MutableProperty<Bool>
    private let _systemVolume: MutableProperty<Float>
    let systemVolume: PropertyOf<Float>
    let muted: PropertyOf<Bool>
    
    init() {
        let nc = NSNotificationCenter.defaultCenter()
        audioSession = AVAudioSession.sharedInstance()
        audioCategory = MutableProperty(audioSession.audioCategory)
        audioCategory <~ nc.rac_notifications(AVAudioSessionRouteChangeNotification, object: nil)
           .map { note -> AudioCategory? in
                Log.debug("Did receive audio route change notification \(note.userInfo)")
                if let reason = (note.userInfo?[AVAudioSessionRouteChangeReasonKey]?.intValue)
                    .flatMap({ AVAudioSessionRouteChangeReason(rawValue: UInt($0)) }),
                    let session = note.object as? AVAudioSession
                    where reason == .CategoryChange {
                    return session.audioCategory
                }
                return nil
            }
           .ignoreNil()
           .observeOn(QueueScheduler.mainQueueScheduler)
        _systemVolume = MutableProperty(audioSession.outputVolume)
        _systemVolume <~ nc.rac_notifications("AVSystemController_SystemVolumeDidChangeNotification", object: nil)
           .map { $0.userInfo?["AVSystemController_AudioVolumeNotificationParameter"]?.floatValue ?? 0 }
        systemVolume = PropertyOf(_systemVolume)
        muteSwitchOn = MutableProperty(false)
        muted = PropertyOf(false, combineLatest(
            muteSwitchOn.producer,
            systemVolume.producer,
            audioCategory.producer
        ).map { muteSwitchOn, volume, category in
            if muteSwitchOn && category.respectsMuteSwitch {
                return true
            }
            return volume == 0
        })
    }
    
    func checkMuteSwitch() {
        muteChecker.check { [weak self] muted in
            self?.muteSwitchOn.value = muted
        }
    }
    
    func getAudioCategory() -> AudioCategory {
        return audioSession.audioCategory
    }
    
    func setAudioCategory(category: AudioCategory) {
        if category != audioSession.audioCategory {
            do {
                if category == .PlaybackAndRecord {
                    let options: AVAudioSessionCategoryOptions = .DefaultToSpeaker
                    try audioSession.setCategory(category.string, withOptions: options)
                } else {
                    try audioSession.setCategory(category.string)
                }
            } catch let error as NSError {
                Log.error("Failed to set audioSession category", error)
            }
            assert(audioSession.audioCategory == category, "Failed to set audio category")
        }
    }
    
    
    
    static let sharedController = AudioController()
}
