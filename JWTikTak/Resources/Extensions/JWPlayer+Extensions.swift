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
