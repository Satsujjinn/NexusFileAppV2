//
//  Haptics.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import UIKit

/// Simple wrapper around ``UIFeedbackGenerator`` types used across the app.
/// Provides one-line static helpers for the common haptic events.
enum Haptics {

    /// Light impact used for selection like feedback.
    static func selection() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Notifies the user of a successful action.
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Warning haptic used for non destructive alerts.
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Error haptic for destructive or failed actions.
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}
