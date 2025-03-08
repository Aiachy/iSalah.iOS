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
                updateAllNotifications(isEnabled: allNotifications)
            }
        }
    }
    
    // Prayer notification toggles
    @Published var fajr: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .fajr, isEnabled: fajr)
                updateIndividualToggleState()
            }
        }
    }
    
    @Published var sunrise: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .sunrise, isEnabled: sunrise)
                updateIndividualToggleState()
            }
        }
    }
    
    @Published var dhuhr: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .dhuhr, isEnabled: dhuhr)
                updateIndividualToggleState()
            }
        }
    }
    
    @Published var asr: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .asr, isEnabled: asr)
                updateIndividualToggleState()
            }
        }
    }
    
    @Published var maghrib: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .maghrib, isEnabled: maghrib)
                updateIndividualToggleState()
            }
        }
    }
    
    @Published var isha: Bool = true {
        didSet {
            if !isUpdatingToggles {
                updateNotificationSetting(for: .isha, isEnabled: isha)
                updateIndividualToggleState()
            }
        }
    }
    
    // Notification permission status
    @Published var isNotificationsAuthorized: Bool = false
    
    // Navigation coordinator
    let coordinator: SettingsCoordinatorPresenter
    
    // Reference to notification manager
    private let notificationManager = NotificationManager.shared
    
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
        self.fajr = notificationManager.notificationSettings[.fajr] ?? true
        self.sunrise = notificationManager.notificationSettings[.sunrise] ?? true
        self.dhuhr = notificationManager.notificationSettings[.dhuhr] ?? true
        self.asr = notificationManager.notificationSettings[.asr] ?? true
        self.maghrib = notificationManager.notificationSettings[.maghrib] ?? true
        self.isha = notificationManager.notificationSettings[.isha] ?? true
        
        // Save previous states
        self.previousFajr = self.fajr
        self.previousSunrise = self.sunrise
        self.previousDhuhr = self.dhuhr
        self.previousAsr = self.asr
        self.previousMaghrib = self.maghrib
        self.previousIsha = self.isha
        
        // Initialize permission status
        self.isNotificationsAuthorized = notificationManager.isNotificationsAuthorized
        
        // Initialize master toggle based on current settings
        updateAllNotificationsState()
    }
    
    // MARK: - Notification Settings
    
    private func updateNotificationSetting(for type: PrayerNotificationType, isEnabled: Bool) {
        notificationManager.updateNotificationSetting(for: type, isEnabled: isEnabled)
        refreshNotifications()
    }
    
    private func updateAllNotifications(isEnabled: Bool) {
        isUpdatingToggles = true
        
        if isEnabled {
            // Ana toggle açılıyorsa, önceki bireysel durumları geri yükle
            fajr = previousFajr
            sunrise = previousSunrise
            dhuhr = previousDhuhr
            asr = previousAsr
            maghrib = previousMaghrib
            isha = previousIsha
        } else {
            // Ana toggle kapanıyorsa, mevcut durumları kaydet ve hepsini kapat
            previousFajr = fajr
            previousSunrise = sunrise
            previousDhuhr = dhuhr
            previousAsr = asr
            previousMaghrib = maghrib
            previousIsha = isha
            
            // Tüm toggle'ları kapat
            fajr = false
            sunrise = false
            dhuhr = false
            asr = false
            maghrib = false
            isha = false
        }
        
        // Tüm toggle'ların durumunu NotificationManager'a ilet
        notificationManager.updateNotificationSetting(for: .fajr, isEnabled: fajr)
        notificationManager.updateNotificationSetting(for: .sunrise, isEnabled: sunrise)
        notificationManager.updateNotificationSetting(for: .dhuhr, isEnabled: dhuhr)
        notificationManager.updateNotificationSetting(for: .asr, isEnabled: asr)
        notificationManager.updateNotificationSetting(for: .maghrib, isEnabled: maghrib)
        notificationManager.updateNotificationSetting(for: .isha, isEnabled: isha)
        
        isUpdatingToggles = false
        refreshNotifications()
    }
    
    private func updateAllNotificationsState() {
        // Check if all individual toggles are enabled
        let allEnabled = [fajr, sunrise, dhuhr, asr, maghrib, isha].allSatisfy { $0 }
        
        // Only update if there's a change to prevent infinite loop
        if allEnabled != allNotifications {
            allNotifications = allEnabled
        }
    }
    
    private func updateIndividualToggleState() {
        // Ana toggle'ın durumunu ayarla, en az bir toggle açıksa ana toggle da açık olmalı
        let anyEnabled = fajr || sunrise || dhuhr || asr || maghrib || isha
        if anyEnabled != allNotifications {
            allNotifications = anyEnabled
        }
    }
    
    private func refreshNotifications() {
        // Only refresh if we have notification permission
        if isNotificationsAuthorized {
            // Trigger a refresh of notifications by using the MosqueCallTimerView mechanism
            NotificationCenter.default.post(name: NSNotification.Name("RefreshPrayerTimes"), object: nil)
        }
    }
    
    // MARK: - Notification Permission
    
    func checkNotificationPermissionStatus() {
        notificationManager.checkNotificationStatus()
        
        // Update our local copy of the permission status
        DispatchQueue.main.async { [weak self] in
            self?.isNotificationsAuthorized = self?.notificationManager.isNotificationsAuthorized ?? false
        }
    }
    
    func requestNotificationPermission() {
        notificationManager.requestAuthorization()
        
        // Check status after a slight delay to allow time for user response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.checkNotificationPermissionStatus()
        }
    }
    
    // MARK: - Test Functionality
    
    func sendTestNotification() {
        notificationManager.sendTestNotification()
    }
    
    // MARK: - Navigation & Other Actions
    
    // Navigation back to settings
    func makeBackButton() {
        coordinator.navigate(to: .settings)
    }
}
