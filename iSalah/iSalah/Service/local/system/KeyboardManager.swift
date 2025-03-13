//
//  KeyboardManager.swift
//  iSalah
//
//  Created on 9.03.2025.
//

import SwiftUI
import Combine

/// A singleton manager class that observes and handles keyboard appearance events.
class KeyboardManager: ObservableObject {
    // MARK: - Singleton
    
    /// Shared instance for app-wide access
    static let shared = KeyboardManager()
    
    // MARK: - Published Properties
    
    /// Indicates whether the keyboard is currently visible
    @Published var isKeyboardVisible = false
    
    /// The current height of the keyboard when visible
    @Published var keyboardHeight: CGFloat = 0
    
    /// The animation duration for keyboard appearance/disappearance
    @Published var keyboardAnimationDuration: Double = 0.25
    
    /// The animation curve for keyboard transitions
    @Published var keyboardAnimationCurve: UInt = 7 // UIView.AnimationCurve.easeInOut
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        registerForKeyboardNotifications()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Private Methods
    private func registerForKeyboardNotifications() {
        // Observe keyboard will show notification
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardNotification(notification, isShowing: true)
            }
            .store(in: &cancellables)
        
        // Observe keyboard will hide notification
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardNotification(notification, isShowing: false)
            }
            .store(in: &cancellables)
    }
    
    private func handleKeyboardNotification(_ notification: Notification, isShowing: Bool) {
        // Update keyboard visibility state
        self.isKeyboardVisible = isShowing
        
        // Extract keyboard animation information from notification
        if let userInfo = notification.userInfo {
            // Get keyboard frame
            if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = isShowing ? keyboardFrame.height : 0
            }
            
            // Get animation duration
            if let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                self.keyboardAnimationDuration = animationDuration
            }
            
            // Get animation curve
            if let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                self.keyboardAnimationCurve = animationCurve
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Dismisses the keyboard by resigning first responder
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - View Extension for Easy Access
extension View {
    /// Applies keyboard awareness to a view
    /// - Returns: A modified view with keyboard awareness
    func keyboardAware() -> some View {
        self.modifier(KeyboardAwareModifier())
    }
}

// MARK: - Keyboard Aware Modifier
struct KeyboardAwareModifier: ViewModifier {
    @ObservedObject var manager = KeyboardManager.shared
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, manager.isKeyboardVisible ? manager.keyboardHeight : 0)
            .animation(.easeOut(duration: manager.keyboardAnimationDuration), value: manager.isKeyboardVisible)
            .onTapGesture {
                // Hide keyboard when tapping outside text fields
                if manager.isKeyboardVisible {
                    manager.dismissKeyboard()
                }
            }
    }
}

// MARK: - Environment Value Extension
struct KeyboardManagerKey: EnvironmentKey {
    static let defaultValue = KeyboardManager.shared
}

extension EnvironmentValues {
    var keyboardManager: KeyboardManager {
        get { self[KeyboardManagerKey.self] }
        set { self[KeyboardManagerKey.self] = newValue }
    }
}
