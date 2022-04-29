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
    public static let shared = HapticsManager()
    private init() {}
    
    // Public
    
    @MainActor
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    @MainActor
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
