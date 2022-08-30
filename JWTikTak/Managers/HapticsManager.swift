//
//  HapticsManager.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import Foundation
import UIKit

/// Encapsulates the haptics logic.
final class HapticsManager {
    // Singleton
    /// Returns the shared haptics manager instance.
    public static let shared = HapticsManager()
    private init() {}
    
    // Public
    
    /// Provides a tactile response to indicate a change in UI selection.
    @MainActor
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    
    @MainActor
    /// Provides a tactile response to indicate successes, failures, and warnings.
    /// - Parameter type: The notification feedback type, indicating that a task has failed (`.error`),
    /// completed successfully (`.success`), or produced a warning (`.warning`).
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
