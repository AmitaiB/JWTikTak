//
//  DefaultJWPlayerDelegates.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import Foundation
import JWPlayerKit

// TODO: Can be considered a Mock delegate object
class DefaultJWPlayerXDelegate: JWPlayerDelegate, JWPlayerStateDelegate {
    // MARK: - JWPlayerDelegate
    func jwplayerIsReady(_ player: JWPlayer) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        print(#function)
    }
    
    
    // MARK: - JWPlayerStateDelegate
    func jwplayerContentWillComplete(_ player: JWPlayer) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, willPlayWithReason reason: JWPlayReason) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, isBufferingWithReason reason: JWBufferReason) {
        print(#function)
    }
    
    func jwplayerContentIsBuffering(_ player: JWPlayer) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, updatedBuffer percent: Double, position time: JWTimeData) {
        print(#function)
    }
    
    func jwplayerContentDidComplete(_ player: JWPlayer) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, isAttemptingToPlay playlistItem: JWPlayerItem, reason: JWPlayReason) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, didPauseWithReason reason: JWPauseReason) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, didBecomeIdleWithReason reason: JWIdleReason) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, isVisible: Bool) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, didLoadPlaylist playlist: [JWPlayerItem]) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, didLoadPlaylistItem item: JWPlayerItem, at index: UInt) {
        print(#function)
    }
    
    func jwplayerPlaylistHasCompleted(_ player: JWPlayer) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, usesMediaType type: JWMediaType) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, seekedFrom oldPosition: TimeInterval, to newPosition: TimeInterval) {
        print(#function)
    }
    
    func jwplayerHasSeeked(_ player: JWPlayer) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, playbackRateChangedTo rate: Double, at time: TimeInterval) {
        print(#function)
    }
    
    func jwplayer(_ player: JWPlayer, updatedCues cues: [JWCue]) {
        print(#function)
    }    
}

