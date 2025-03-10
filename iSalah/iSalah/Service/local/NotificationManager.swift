//
//  NotificationManager.swift
//  iSalah
//
//  Created on 27.02.2025.
//
import Foundation
import UserNotifications
import SwiftUI
import CoreLocation

enum PrayerNotificationType: String, CaseIterable, Codable {
    case fajr = "Fajr"
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
    
    var localizedKey: LocalizedStringKey {
        return LocalizedStringKey(self.rawValue)
    }
}

class NotificationManager {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let allNotificationsKey = "iSalah.Notifications.AllEnabled"
    private let notificationSettingsKey = "iSalah.Notifications.Settings"
    private let lastScheduleDateKey = "iSalah.Notifications.LastScheduleDate"
    
    // Cache the latest prayer times for current day
    private var latestPrayerTimes: [PrayerTime] = []
    
    // Cache for weekly prayer times by date string
    private var weeklyPrayerTimesCache: [String: [PrayerTime]] = [:]
    
    private init() {
        // Initialize defaults if not set
        if userDefaults.object(forKey: notificationSettingsKey) == nil {
            // Default all prayer types to enabled
            let defaultSettings: [String: Bool] = PrayerNotificationType.allCases.reduce(into: [:]) { dict, type in
                dict[type.rawValue] = true
            }
            userDefaults.set(defaultSettings, forKey: notificationSettingsKey)
        }
        
        if userDefaults.object(forKey: allNotificationsKey) == nil {
            userDefaults.set(true, forKey: allNotificationsKey)
        }
    }
    
    // MARK: - Notification Authorization
    
    // Request notification permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("iSalah: Error requesting notification authorization: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // Check if notifications are authorized
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            DispatchQueue.main.async {
                completion(isAuthorized)
            }
        }
    }
    
    // MARK: - Notification Settings
    
    // Get whether all notifications are enabled
    var areAllNotificationsEnabled: Bool {
        get {
            return userDefaults.bool(forKey: allNotificationsKey)
        }
        set {
            userDefaults.set(newValue, forKey: allNotificationsKey)
            
            // If turning on all notifications, reschedule notifications
            if newValue {
                refreshPrayerNotifications()
            } else {
                // If turning off all notifications, cancel all
                cancelAllPendingPrayerNotifications()
            }
        }
    }
    
    // Get whether a specific prayer notification is enabled
    func isNotificationEnabled(for prayerType: PrayerNotificationType) -> Bool {
        guard let settings = userDefaults.dictionary(forKey: notificationSettingsKey) as? [String: Bool] else {
            return true // Default to true if settings not found
        }
        return settings[prayerType.rawValue] ?? true
    }
    
    // Set whether a specific prayer notification is enabled
    func setNotificationEnabled(_ enabled: Bool, for prayerType: PrayerNotificationType) {
        guard var settings = userDefaults.dictionary(forKey: notificationSettingsKey) as? [String: Bool] else {
            // If settings not found, create new with all enabled
            var newSettings: [String: Bool] = PrayerNotificationType.allCases.reduce(into: [:]) { dict, type in
                dict[type.rawValue] = true
            }
            newSettings[prayerType.rawValue] = enabled
            userDefaults.set(newSettings, forKey: notificationSettingsKey)
            refreshPrayerNotifications()
            return
        }
        
        settings[prayerType.rawValue] = enabled
        userDefaults.set(settings, forKey: notificationSettingsKey)
        
        // Refresh notifications to apply changes
        refreshPrayerNotifications()
    }
    
    // Set all prayer notifications enabled/disabled
    func setAllPrayerNotificationsEnabled(_ enabled: Bool) {
        let settings: [String: Bool] = PrayerNotificationType.allCases.reduce(into: [:]) { dict, type in
            dict[type.rawValue] = enabled
        }
        userDefaults.set(settings, forKey: notificationSettingsKey)
        
        // Update master toggle
        userDefaults.set(enabled, forKey: allNotificationsKey)
        
        // Refresh notifications to apply changes
        if enabled {
            refreshPrayerNotifications()
        } else {
            cancelAllPendingPrayerNotifications()
        }
    }
    
    // MARK: - Weekly Notification Scheduling
    
    // Schedule notifications for the upcoming week
    func scheduleWeeklyPrayerNotifications(for location: LocationSuggestion) async {
        print("iSalah: NotificationManager - scheduleWeeklyPrayerNotifications")
        
        // If all notifications are disabled, don't schedule any
        if !areAllNotificationsEnabled {
            print("iSalah: All notifications disabled, not scheduling any weekly notifications")
            return
        }
        
        // Check if we've already scheduled notifications today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get the last schedule date from UserDefaults
        if let lastScheduleDate = userDefaults.object(forKey: lastScheduleDateKey) as? Date {
            let lastScheduleDay = calendar.startOfDay(for: lastScheduleDate)
            
            // If we've already scheduled today and it's not force refreshing, skip
            if calendar.isDate(today, inSameDayAs: lastScheduleDay) {
                print("iSalah: Already scheduled notifications today, skipping")
                return
            }
        }
        
        // First remove any existing prayer notifications
        cancelAllPendingPrayerNotifications()
        
        // Clear weekly cache
        weeklyPrayerTimesCache.removeAll()
        
        // Get prayer times for current day and the next 6 days (total 7 days)
        var allPrayerTimes: [PrayerTime] = []
        
        // Get today's prayer times
        let todayPrayerTimes = await PrayerTimeService.shared.getPrayerTimes(for: location)
        allPrayerTimes.append(contentsOf: todayPrayerTimes)
        
        // Cache today's prayer times
        self.latestPrayerTimes = todayPrayerTimes
        
        // Store in weekly cache
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        weeklyPrayerTimesCache[todayString] = todayPrayerTimes
        
        // Get prayer times for the next 6 days
        for dayOffset in 1...6 {
            guard let nextDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }
            
            let nextDateString = dateFormatter.string(from: nextDate)
            let nextDayPrayerTimes = await PrayerTimeService.shared.getPrayerTimes(for: location, on: nextDate)
            
            allPrayerTimes.append(contentsOf: nextDayPrayerTimes)
            weeklyPrayerTimesCache[nextDateString] = nextDayPrayerTimes
        }
        
        print("iSalah: Got prayer times for 7 days, total \(allPrayerTimes.count) prayer times")
        
        // Schedule notifications for all prayer times
        for prayerTime in allPrayerTimes {
            // Skip if the prayer time has already passed
            if prayerTime.isPassed {
                continue
            }
            
            // Get the prayer type from the prayer time
            let prayerType = getPrayerType(from: prayerTime)
            
            // Skip if this prayer type is disabled
            if let type = prayerType, !isNotificationEnabled(for: type) {
                continue
            }
            
            // Schedule notification for this prayer time
            scheduleNotification(for: prayerTime)
        }
        
        // Save the current date as the last schedule date
        userDefaults.set(Date(), forKey: lastScheduleDateKey)
        
        print("iSalah: Successfully scheduled weekly prayer notifications")
    }
    
    // Schedule notifications for all prayer times (single day - kept for compatibility)
    func schedulePrayerNotifications(for prayerTimes: [PrayerTime]) {
        print("iSalah: NotificationManager - schedulePrayerNotifications (single day)")
        
        // Store these prayer times for later refresh if needed
        self.latestPrayerTimes = prayerTimes
        
        // If all notifications are disabled, don't schedule any
        if !areAllNotificationsEnabled {
            print("iSalah: All notifications disabled, not scheduling any")
            return
        }
        
        // Schedule new notifications for each prayer time that is enabled
        for prayerTime in prayerTimes {
            // Skip if the prayer time has already passed
            if prayerTime.isPassed {
                print("iSalah: Skipping notification for passed prayer time: \(prayerTime.name)")
                continue
            }
            
            // Get the prayer type from the prayer time
            let prayerType = getPrayerType(from: prayerTime)
            
            // Skip if this prayer type is disabled
            if let type = prayerType, !isNotificationEnabled(for: type) {
                print("iSalah: Skipping notification for disabled prayer type: \(type.rawValue)")
                continue
            }
            
            // Create notification for this prayer time
            scheduleNotification(for: prayerTime)
        }
    }
    
    // Refresh notifications based on current settings
    func refreshPrayerNotifications() {
        // If we have weekly prayer times cached, use those
        if !weeklyPrayerTimesCache.isEmpty {
            print("iSalah: Refreshing notifications with weekly prayer times")
            
            // Cancel existing notifications
            cancelAllPendingPrayerNotifications()
            
            // If all notifications are disabled, don't schedule any
            if !areAllNotificationsEnabled {
                return
            }
            
            // Reschedule all upcoming prayer times from the weekly cache
            let now = Date()
            let calendar = Calendar.current
            
            for (_, prayerTimes) in weeklyPrayerTimesCache {
                for prayerTime in prayerTimes {
                    // Skip if already passed
                    if prayerTime.time < now {
                        continue
                    }
                    
                    // Get the prayer type
                    let prayerType = getPrayerType(from: prayerTime)
                    
                    // Skip if this type is disabled
                    if let type = prayerType, !isNotificationEnabled(for: type) {
                        continue
                    }
                    
                    // Schedule the notification
                    scheduleNotification(for: prayerTime)
                }
            }
        } else if !latestPrayerTimes.isEmpty {
            // Fall back to single day if weekly cache is empty
            schedulePrayerNotifications(for: latestPrayerTimes)
        }
    }
    
    // Schedule a notification for a specific prayer time
    private func scheduleNotification(for prayerTime: PrayerTime) {
        let content = UNMutableNotificationContent()
        
        // Extract the prayer name key as string for identification
        let prayerNameString = getPrayerNameString(from: prayerTime.name)
        
        // Set notification content
        content.title = "Prayer Time"
        content.body = "It's time for prayer"
        
        // Try to determine the specific prayer type for better notification message
        for prayerType in PrayerNotificationType.allCases {
            if prayerNameString.contains(prayerType.rawValue) {
                content.title = "\(prayerType.rawValue) Prayer Time"
                content.body = "It's time for \(prayerType.rawValue) prayer"
                break
            }
        }
        
        content.sound = UNNotificationSound.default
        
        // Include the date in the notification identifier to make it unique across days
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: prayerTime.time)
        
        // Create a unique identifier for this notification
        let identifier = "iSalah.Prayer.\(dateString).\(prayerTime.id.uuidString)"
        
        // Create a date components trigger for the exact prayer time
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: prayerTime.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        // Create the notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("iSalah: Error scheduling notification for \(prayerNameString) on \(dateString): \(error.localizedDescription)")
            } else {
                // Format date for logging
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let formattedDate = dateFormatter.string(from: prayerTime.time)
                
                print("iSalah: Successfully scheduled notification for \(prayerNameString) at \(prayerTime.timeString) on \(formattedDate)")
            }
        }
    }
    
    // Helper function to extract prayer name as string from LocalizedStringKey
    private func getPrayerNameString(from localizedKey: LocalizedStringKey) -> String {
        let mirror = Mirror(reflecting: localizedKey)
        for child in mirror.children {
            if child.label == "key" {
                return child.value as? String ?? "Prayer"
            }
        }
        return "Prayer"
    }
    
    // Helper function to get prayer type from prayer time
    private func getPrayerType(from prayerTime: PrayerTime) -> PrayerNotificationType? {
        let prayerNameString = getPrayerNameString(from: prayerTime.name)
        return PrayerNotificationType.allCases.first {
            prayerNameString.contains($0.rawValue)
        }
    }
    
    // Cancel all pending prayer notifications
    func cancelAllPendingPrayerNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            let prayerNotifications = requests.filter { $0.identifier.hasPrefix("iSalah.Prayer.") }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: prayerNotifications.map { $0.identifier })
            print("iSalah: Cancelled \(prayerNotifications.count) pending prayer notifications")
        }
    }
    
    // Get all pending prayer notifications
    func getPendingPrayerNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            let prayerNotifications = requests.filter { $0.identifier.hasPrefix("iSalah.Prayer.") }
            DispatchQueue.main.async {
                completion(prayerNotifications)
            }
        }
    }
}
