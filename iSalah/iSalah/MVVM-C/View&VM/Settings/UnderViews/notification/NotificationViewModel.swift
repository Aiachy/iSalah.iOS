//
//  NotificationViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation
import SwiftUI

class NotificationViewModel: ObservableObject {
    
    // Prayer notification toggles
    @Published var fajr: Bool {
        didSet {
            updateNotificationSetting(for: .fajr, isEnabled: fajr)
        }
    }
    
    @Published var sunrise: Bool {
        didSet {
            updateNotificationSetting(for: .sunrise, isEnabled: sunrise)
        }
    }
    
    @Published var dhuhr: Bool {
        didSet {
            updateNotificationSetting(for: .dhuhr, isEnabled: dhuhr)
        }
    }
    
    @Published var asr: Bool {
        didSet {
            updateNotificationSetting(for: .asr, isEnabled: asr)
        }
    }
    
    @Published var maghrib: Bool {
        didSet {
            updateNotificationSetting(for: .maghrib, isEnabled: maghrib)
        }
    }
    
    @Published var isha: Bool {
        didSet {
            updateNotificationSetting(for: .isha, isEnabled: isha)
        }
    }
    
    // Navigation coordinator
    let coordinator: SettingsCoordinatorPresenter
    
    // Reference to notification manager
    private let notificationManager = NotificationManager.shared
    
    init(
        coordinator: SettingsCoordinatorPresenter
    ) {
        self.coordinator = coordinator
        
        self.fajr = notificationManager.notificationSettings[.fajr] ?? true
        self.sunrise = notificationManager.notificationSettings[.sunrise] ?? true
        self.dhuhr = notificationManager.notificationSettings[.dhuhr] ?? true
        self.asr = notificationManager.notificationSettings[.asr] ?? true
        self.maghrib = notificationManager.notificationSettings[.maghrib] ?? true
        self.isha = notificationManager.notificationSettings[.isha] ?? true
        
        notificationManager.requestAuthorization()
    }
    
    private func updateNotificationSetting(for type: PrayerNotificationType, isEnabled: Bool) {
        notificationManager.updateNotificationSetting(for: type, isEnabled: isEnabled)
    }
    
}

extension NotificationViewModel {
    // Navigation back to settings
    func makeBackButton() {
        coordinator.navigate(to: .settings)
    }
    
    // Method to manually update location and refresh notifications
    func updateLocation(_ location: LocationSuggestion) {
        notificationManager.updateLocation(location)
    }
}
