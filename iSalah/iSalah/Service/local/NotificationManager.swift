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
    private let allNotificationsKey = "iSalah.Notifications.AllEnabled"
    private let notificationSettingsKey = "iSalah.Notifications.Settings"
    private let lastScheduleDateKey = "iSalah.Notifications.LastScheduleDate"
    
    private var latestPrayerTimes: [PrayerTime] = []
    private var weeklyPrayerTimesCache: [String: [PrayerTime]] = [:]
    private var isSchedulingInProgress = false
    
    private init() {
        if userDefaults.object(forKey: notificationSettingsKey) == nil {
            let defaultSettings: [String: Bool] = PrayerNotificationType.allCases.reduce(into: [:]) { $0[$1.rawValue] = true }
            userDefaults.set(defaultSettings, forKey: notificationSettingsKey)
        }
        
        if userDefaults.object(forKey: allNotificationsKey) == nil {
            userDefaults.set(true, forKey: allNotificationsKey)
        }
    }
    
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
    
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    var areAllNotificationsEnabled: Bool {
        get { return userDefaults.bool(forKey: allNotificationsKey) }
        set {
            userDefaults.set(newValue, forKey: allNotificationsKey)
            newValue ? refreshPrayerNotifications() : cancelAllPendingPrayerNotifications()
        }
    }
    
    func isNotificationEnabled(for prayerType: PrayerNotificationType) -> Bool {
        guard let settings = userDefaults.dictionary(forKey: notificationSettingsKey) as? [String: Bool] else {
            return true
        }
        return settings[prayerType.rawValue] ?? true
    }
    
    func setNotificationEnabled(_ enabled: Bool, for prayerType: PrayerNotificationType) {
        guard var settings = userDefaults.dictionary(forKey: notificationSettingsKey) as? [String: Bool] else {
            var newSettings: [String: Bool] = PrayerNotificationType.allCases.reduce(into: [:]) { $0[$1.rawValue] = true }
            newSettings[prayerType.rawValue] = enabled
            userDefaults.set(newSettings, forKey: notificationSettingsKey)
            refreshPrayerNotifications()
            return
        }
        
        settings[prayerType.rawValue] = enabled
        userDefaults.set(settings, forKey: notificationSettingsKey)
        refreshPrayerNotifications()
    }
    
    func setAllPrayerNotificationsEnabled(_ enabled: Bool) {
        let settings: [String: Bool] = PrayerNotificationType.allCases.reduce(into: [:]) { $0[$1.rawValue] = enabled }
        userDefaults.set(settings, forKey: notificationSettingsKey)
        userDefaults.set(enabled, forKey: allNotificationsKey)
        
        enabled ? refreshPrayerNotifications() : cancelAllPendingPrayerNotifications()
    }
    
    func scheduleWeeklyPrayerNotifications(for location: LocationSuggestion) async {
        // Skip if all notifications are disabled or scheduling is already in progress
        if !areAllNotificationsEnabled || isSchedulingInProgress {
            return
        }
        
        // Check if we already scheduled today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastScheduleDate = userDefaults.object(forKey: lastScheduleDateKey) as? Date {
            if calendar.isDate(today, inSameDayAs: calendar.startOfDay(for: lastScheduleDate)) {
                return
            }
        }
        
        isSchedulingInProgress = true
        
        // Cancel existing notifications before scheduling new ones
        await withCheckedContinuation { continuation in
            cancelAllPendingPrayerNotifications {
                continuation.resume()
            }
        }
        
        weeklyPrayerTimesCache.removeAll()
        var allPrayerTimes: [PrayerTime] = []
        
        // Today's prayer times
        let todayPrayerTimes = await PrayerTimeService.shared.getPrayerTimes(for: location)
        allPrayerTimes.append(contentsOf: todayPrayerTimes)
        latestPrayerTimes = todayPrayerTimes
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        weeklyPrayerTimesCache[dateFormatter.string(from: today)] = todayPrayerTimes
        
        // Next 6 days prayer times
        for dayOffset in 1...6 {
            guard let nextDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            let nextDateString = dateFormatter.string(from: nextDate)
            let nextDayPrayerTimes = await PrayerTimeService.shared.getPrayerTimes(for: location, on: nextDate)
            
            allPrayerTimes.append(contentsOf: nextDayPrayerTimes)
            weeklyPrayerTimesCache[nextDateString] = nextDayPrayerTimes
        }
        
        // Schedule notifications for all upcoming prayer times
        let now = Date()
        for prayerTime in allPrayerTimes {
            if prayerTime.time > now,
               let prayerType = getPrayerType(from: prayerTime),
               isNotificationEnabled(for: prayerType) {
                scheduleNotification(for: prayerTime)
            }
        }
        
        userDefaults.set(Date(), forKey: lastScheduleDateKey)
        isSchedulingInProgress = false
    }
    
    func schedulePrayerNotifications(for prayerTimes: [PrayerTime]) {
        if !areAllNotificationsEnabled { return }
        
        latestPrayerTimes = prayerTimes
        let now = Date()
        
        for prayerTime in prayerTimes {
            if prayerTime.time <= now { continue }
            
            if let prayerType = getPrayerType(from: prayerTime),
               !isNotificationEnabled(for: prayerType) {
                continue
            }
            
            // Only schedule single-day notifications if weekly scheduling hasn't happened yet
            if userDefaults.object(forKey: lastScheduleDateKey) == nil {
                scheduleNotification(for: prayerTime)
            }
        }
    }
    
    func refreshPrayerNotifications() {
        if !areAllNotificationsEnabled { return }
        
        cancelAllPendingPrayerNotifications {
            let now = Date()
            
            // Use cached weekly prayer times if available
            if !self.weeklyPrayerTimesCache.isEmpty {
                for (_, prayerTimes) in self.weeklyPrayerTimesCache {
                    for prayerTime in prayerTimes {
                        if prayerTime.time <= now { continue }
                        
                        if let prayerType = self.getPrayerType(from: prayerTime),
                           !self.isNotificationEnabled(for: prayerType) {
                            continue
                        }
                        
                        self.scheduleNotification(for: prayerTime)
                    }
                }
            } else if !self.latestPrayerTimes.isEmpty {
                // Fall back to today's prayer times
                self.schedulePrayerNotifications(for: self.latestPrayerTimes)
            }
        }
    }
    
    private func scheduleNotification(for prayerTime: PrayerTime) {
        let content = UNMutableNotificationContent()
        let prayerNameString = getPrayerNameString(from: prayerTime.name)
        
        // Set default content
        content.title = "Prayer Time"
        content.body = "It's time for prayer"
        
        // Customize for specific prayer type
        if let prayerType = getPrayerType(from: prayerTime) {
            content.title = "\(prayerType.rawValue) Prayer Time"
            content.body = "It's time for \(prayerType.rawValue) prayer"
        }
        
        content.sound = UNNotificationSound.default
        
        // Create a unique identifier based on date and time (not UUID which can cause duplicates)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmm"
        let dateTimeString = dateFormatter.string(from: prayerTime.time)
        let identifier = "iSalah.Prayer.\(dateTimeString).\(prayerNameString)"
        
        // Create calendar trigger for exact time
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: prayerTime.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        // Create and schedule the notification
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("iSalah: Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func getPrayerNameString(from localizedKey: LocalizedStringKey) -> String {
        let mirror = Mirror(reflecting: localizedKey)
        for child in mirror.children where child.label == "key" {
            return child.value as? String ?? "Prayer"
        }
        return "Prayer"
    }
    
    private func getPrayerType(from prayerTime: PrayerTime) -> PrayerNotificationType? {
        let prayerNameString = getPrayerNameString(from: prayerTime.name)
        return PrayerNotificationType.allCases.first { prayerNameString.contains($0.rawValue) }
    }
    
    func cancelAllPendingPrayerNotifications(completion: (() -> Void)? = nil) {
        notificationCenter.getPendingNotificationRequests { requests in
            let prayerNotifications = requests.filter { $0.identifier.hasPrefix("iSalah.Prayer.") }
            self.notificationCenter.removePendingNotificationRequests(
                withIdentifiers: prayerNotifications.map { $0.identifier }
            )
            completion?()
        }
    }
    
    func getPendingPrayerNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            let prayerNotifications = requests.filter { $0.identifier.hasPrefix("iSalah.Prayer.") }
            DispatchQueue.main.async {
                completion(prayerNotifications)
            }
        }
    }
}
