//
//  DefaultJWPlayerDelegates.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import Foundation
import JWPlayerKit

let debug = false

// TODO: Can be considered a Mock delegate object
// TODO: OR, switch to os Logger.
class DefaultJWPlayerXDelegate: JWPlayerDelegate, JWPlayerStateDelegate {
    // MARK: - JWPlayerDelegate
    func jwplayerIsReady(_ player: JWPlayer) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        if debug { print(#function) }
    }
    
    
    // MARK: - JWPlayerStateDelegate
    func jwplayerContentWillComplete(_ player: JWPlayer) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, willPlayWithReason reason: JWPlayReason) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, isBufferingWithReason reason: JWBufferReason) {
        if debug { print(#function) }
    }
    
    func jwplayerContentIsBuffering(_ player: JWPlayer) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, updatedBuffer percent: Double, position time: JWTimeData) {
        if debug { print(#function) }
    }
    
    func jwplayerContentDidComplete(_ player: JWPlayer) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, isAttemptingToPlay playlistItem: JWPlayerItem, reason: JWPlayReason) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, didPauseWithReason reason: JWPauseReason) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, didBecomeIdleWithReason reason: JWIdleReason) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, isVisible: Bool) {
        isVisible ? player.play() : player.pause()
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, didLoadPlaylist playlist: [JWPlayerItem]) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, didLoadPlaylistItem item: JWPlayerItem, at index: UInt) {
        if debug { print(#function) }
    }
    
    func jwplayerPlaylistHasCompleted(_ player: JWPlayer) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, usesMediaType type: JWMediaType) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, seekedFrom oldPosition: TimeInterval, to newPosition: TimeInterval) {
        if debug { print(#function) }
    }
    
    func jwplayerHasSeeked(_ player: JWPlayer) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, playbackRateChangedTo rate: Double, at time: TimeInterval) {
        if debug { print(#function) }
    }
    
    func jwplayer(_ player: JWPlayer, updatedCues cues: [JWCue]) {
        if debug { print(#function) }
    }
}

