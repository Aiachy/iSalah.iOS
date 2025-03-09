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
    
    // Store previous individual toggle states
    private var previousFajr = true
    private var previousSunrise = true
    private var previousDhuhr = true
    private var previousAsr = true
    private var previousMaghrib = true
    private var previousIsha = true
    
    init(
        coordinator: SettingsCoordinatorPresenter
    ) {
        self.coordinator = coordinator
        
        // Initialize notification settings from NotificationManager
        self.fajr = true
        self.sunrise = true
        self.dhuhr = true
        self.asr = true
        self.maghrib = true
        self.isha = true
        
        // Save previous states
        self.previousFajr = self.fajr
        self.previousSunrise = self.sunrise
        self.previousDhuhr = self.dhuhr
        self.previousAsr = self.asr
        self.previousMaghrib = self.maghrib
        self.previousIsha = self.isha
                
    }
    
    // MARK: - Notification Settings
    
    private func updateNotificationSetting(for type: PrayerNotificationType, isEnabled: Bool) {
    }
    

   
    

  
}
// MARK: - Navigation & Other Actions
extension NotificationViewModel {
    
    // Navigation back to settings
    func makeBackButton() {
        coordinator.navigate(to: .settings)
    }
}
