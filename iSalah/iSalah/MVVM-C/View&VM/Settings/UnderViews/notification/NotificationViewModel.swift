//
//  NotificationViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation
import SwiftUI

class NotificationViewModel: ObservableObject {
    
    // Master toggle for all notifications
    @Published var allNotifications: Bool = true {
        didSet {
            if oldValue != allNotifications {
                NotificationManager.shared.areAllNotificationsEnabled = allNotifications
                
                // If turning off all notifications, we don't need to update individual settings
                if !allNotifications {
                    return
                }
                
                // When turning on all notifications, restore individual settings
                isUpdatingToggles = true
                
                // Update UI to match stored settings
                fajr = NotificationManager.shared.isNotificationEnabled(for: .fajr)
                sunrise = NotificationManager.shared.isNotificationEnabled(for: .sunrise)
                dhuhr = NotificationManager.shared.isNotificationEnabled(for: .dhuhr)
                asr = NotificationManager.shared.isNotificationEnabled(for: .asr)
                maghrib = NotificationManager.shared.isNotificationEnabled(for: .maghrib)
                isha = NotificationManager.shared.isNotificationEnabled(for: .isha)
                
                isUpdatingToggles = false
            }
        }
    }
    
    // Prayer notification toggles
    @Published var fajr: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .fajr, isEnabled: fajr)
            }
        }
    }
    
    @Published var sunrise: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .sunrise, isEnabled: sunrise)
            }
        }
    }
    
    @Published var dhuhr: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .dhuhr, isEnabled: dhuhr)
            }
        }
    }
    
    @Published var asr: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .asr, isEnabled: asr)
            }
        }
    }
    
    @Published var maghrib: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .maghrib, isEnabled: maghrib)
            }
        }
    }
    
    @Published var isha: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .isha, isEnabled: isha)
            }
        }
    }
    
    // Notification permission status
    @Published var isNotificationsAuthorized: Bool = false
    
    // Navigation coordinator
    let coordinator: SettingsCoordinatorPresenter
    
    
    // Flag to prevent multiple updates
    private var isUpdatingToggles = false
    
    init(
        coordinator: SettingsCoordinatorPresenter
    ) {
        self.coordinator = coordinator
        
        // Check notification authorization status
        NotificationManager.shared.checkAuthorizationStatus { isAuthorized in
            self.isNotificationsAuthorized = isAuthorized
        }
        
        // Initialize master toggle from NotificationManager
        self.allNotifications = NotificationManager.shared.areAllNotificationsEnabled
        
        // Initialize notification settings from NotificationManager
        self.isUpdatingToggles = true
        self.fajr = NotificationManager.shared.isNotificationEnabled(for: .fajr)
        self.sunrise = NotificationManager.shared.isNotificationEnabled(for: .sunrise)
        self.dhuhr = NotificationManager.shared.isNotificationEnabled(for: .dhuhr)
        self.asr = NotificationManager.shared.isNotificationEnabled(for: .asr)
        self.maghrib = NotificationManager.shared.isNotificationEnabled(for: .maghrib)
        self.isha = NotificationManager.shared.isNotificationEnabled(for: .isha)
        self.isUpdatingToggles = false
    }
    
    // MARK: - Notification Settings
    
    private func updateNotificationSetting(for type: PrayerNotificationType, isEnabled: Bool) {
        // Update the setting in NotificationManager
        NotificationManager.shared.setNotificationEnabled(isEnabled, for: type)
        
        // Check if all individual settings are turned off
        let allOff = ![fajr, sunrise, dhuhr, asr, maghrib, isha].contains(true)
        
        // If all individual settings are off, turn off the master toggle
        if allOff && allNotifications {
            isUpdatingToggles = true
            allNotifications = false
            isUpdatingToggles = false
        }
        
        // If any individual setting is on but master is off, turn on master
        let anyOn = [fajr, sunrise, dhuhr, asr, maghrib, isha].contains(true)
        if anyOn && !allNotifications {
            isUpdatingToggles = true
            allNotifications = true
            isUpdatingToggles = false
        }
    }
    
    // Request notification permissions
    func requestNotificationPermissions() {
        NotificationManager.shared.requestAuthorization { granted in
            self.isNotificationsAuthorized = granted
        }
    }
}

// MARK: - Navigation & Other Actions
extension NotificationViewModel {
    
    // Navigation back to settings
    func makeBackButton() {
        coordinator.navigate(to: .settings)
    }
}
