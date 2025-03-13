//
//  HapticManager.swift
//  iSalah
//
//  Created on 27.02.2025.
//

import SwiftUI
import UIKit

class HapticManager {
    
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Feedback Types
    
    enum FeedbackType {
        case light     // Light impact for subtle feedback
        case medium    // Medium impact for standard feedback
        case heavy     // Heavy impact for significant feedback
        case success   // Success notification
        case warning   // Warning notification
        case error     // Error notification
        case selection // Selection feedback (light tap)
    }
    
    // MARK: - Haptic Generator Properties
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - Public Methods
    
    /// Triggers haptic feedback based on the specified type
    /// - Parameter type: The type of haptic feedback to generate
    func trigger(_ type: FeedbackType) {
        switch type {
        case .light:
            impactLight.prepare()
            impactLight.impactOccurred()
            
        case .medium:
            impactMedium.prepare()
            impactMedium.impactOccurred()
            
        case .heavy:
            impactHeavy.prepare()
            impactHeavy.impactOccurred()
            
        case .success:
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.success)
            
        case .warning:
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.warning)
            
        case .error:
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(.error)
            
        case .selection:
            selectionGenerator.prepare()
            selectionGenerator.selectionChanged()
        }
    }
    
    /// Generates a custom pattern of haptic feedback
    /// - Parameter pattern: Array of tuples containing the feedback type and delay in seconds
    func playPattern(pattern: [(type: FeedbackType, delay: TimeInterval)]) {
        guard !pattern.isEmpty else { return }
        
        var currentIndex = 0
        
        func playNext() {
            guard currentIndex < pattern.count else { return }
            
            let item = pattern[currentIndex]
            trigger(item.type)
            
            currentIndex += 1
            
            if currentIndex < pattern.count {
                let nextDelay = pattern[currentIndex - 1].delay
                DispatchQueue.main.asyncAfter(deadline: .now() + nextDelay) {
                    playNext()
                }
            }
        }
        
        playNext()
    }
    
    /// Triggers haptic feedback when prayer time is about to begin (30 seconds before)
    func prayerTimeApproaching() {
        playPattern(pattern: [
            (.medium, 0.3),
            (.medium, 0.3),
            (.heavy, 0.0)
        ])
    }
    
    /// Triggers haptic feedback for prayer time notifications
    func prayerTimeNotification() {
        playPattern(pattern: [
            (.success, 0.0)
        ])
    }
    
    /// Triggers haptic feedback for location changes
    func locationChanged() {
        playPattern(pattern: [
            (.light, 0.1),
            (.medium, 0.0)
        ])
    }
    
    /// Triggers haptic feedback for button presses
    func buttonPress() {
        trigger(.light)
    }
    
    /// Triggers haptic feedback for tab selection
    func tabSelection() {
        trigger(.selection)
    }
    
    /// Triggers haptic feedback for errors
    func error() {
        trigger(.error)
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Adds haptic feedback to a view when triggered
    /// - Parameters:
    ///   - type: The type of haptic feedback to generate
    ///   - trigger: Binding that triggers the haptic when changed to true
    /// - Returns: Modified view with haptic feedback capability
    func hapticFeedback(_ type: HapticManager.FeedbackType, when trigger: Binding<Bool>) -> some View {
        self.onChange(of: trigger.wrappedValue) { oldValue, newValue in
            if newValue == true {
                HapticManager.shared.trigger(type)
                // Automatically reset the trigger
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    trigger.wrappedValue = false
                }
            }
        }
    }
    
    /// Adds haptic feedback to a button press
    /// - Parameter type: The type of haptic feedback to generate (defaults to .light)
    /// - Returns: Modified view with haptic feedback on press
    func buttonHaptic(_ type: HapticManager.FeedbackType = .light) -> some View {
        self.simultaneousGesture(TapGesture().onEnded { _ in
            HapticManager.shared.trigger(type)
        })
    }
}

// MARK: - Example Usage

/*
 Example usage in views:
 
 // Basic trigger
 Button("Test Haptic") {
     HapticManager.shared.trigger(.medium)
 }
 
 // Custom pattern
 Button("Play Pattern") {
     HapticManager.shared.playPattern(pattern: [
         (.light, 0.2),
         (.medium, 0.3),
         (.heavy, 0.0)
     ])
 }
 
 // Using the View extension with a trigger binding
 @State private var hapticTrigger = false
 
 Button("Trigger Haptic") {
     hapticTrigger = true
 }
 .hapticFeedback(.success, when: $hapticTrigger)
 
 // Using the buttonHaptic modifier
 Button("Button with Haptic") {
     // Action code
 }
 .buttonHaptic(.medium)
 
 // Prayer time specific
 Button("Simulate Prayer Time") {
     HapticManager.shared.prayerTimeNotification()
 }
 */
