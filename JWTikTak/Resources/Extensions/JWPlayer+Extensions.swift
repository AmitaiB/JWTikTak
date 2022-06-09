//
//  JWPlayer+Extensions.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import Foundation
import JWPlayerKit

/// Typealias for ``JWPlayerKit/JWPlayerConfiguration``.
typealias JWPlayerConfig        = JWPlayerConfiguration

/// Typealias for ``JWPlayerKit/JWPlayerConfigurationBuilder``.
typealias JWPlayerConfigBuilder = JWPlayerConfigurationBuilder

extension JWPlayer {
    var isPlaying: Bool { getState() == .playing }
    
    func togglePlayback() {
        if isPlaying { pause() }
        else         { play()  }
    }
}

fileprivate let kVolumeKey = "kVolumeKey"
extension JWPlayer {
    func mute() {
        guard !isMuted else { return }
        originalVolume = volume
        volume = 0
    }
    
    func unmute() {
        guard isMuted else { return }
        volume = originalVolume ?? 1
        originalVolume = nil
    }
    
    var isMuted: Bool {
        get { volume == 0 }
        set { newValue ? mute() : unmute() }
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    var originalVolume: CGFloat? {
        get { UserDefaults.standard.value(forKey: kVolumeKey) as? CGFloat }
        set { UserDefaults.standard.set(newValue, forKey: kVolumeKey)     }
    }
}
