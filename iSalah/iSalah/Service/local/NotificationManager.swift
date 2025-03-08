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

enum PrayerNotificationType: String, CaseIterable {
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

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var notificationSettings = [PrayerNotificationType: Bool]()
    @Published var isNotificationsAuthorized = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private var currentLocation: LocationSuggestion?
    
    // Debug mode flag (enable for detailed logs)
    private let debugMode = true
    
    private override init() {
        super.init()
        
        // Default to enabling all notification types
        for type in PrayerNotificationType.allCases {
            notificationSettings[type] = true
        }
        
        notificationCenter.delegate = self
        
        // Check current authorization status on startup
        checkNotificationStatus()
    }
    
    // MARK: - Authorization Management
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if let error = error {
                self?.logDebug("❌ Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.isNotificationsAuthorized = granted
                if granted {
                    self?.logDebug("✅ Notification permission granted")
                    // Schedule notifications if we have a location
                    if let location = self?.currentLocation {
                        Task {
                            await self?.schedulePrayerNotifications(for: location, days: 7)
                        }
                    }
                } else {
                    self?.logDebug("⚠️ Notification permission denied")
                }
            }
        }
    }
    
    func checkNotificationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isNotificationsAuthorized = settings.authorizationStatus == .authorized
                self?.logDebug("📋 Notification authorization status: \(settings.authorizationStatus.rawValue)")
                
                // If authorized, make sure we have notifications scheduled
                if settings.authorizationStatus == .authorized, let location = self?.currentLocation {
                    Task {
                        await self?.schedulePrayerNotifications(for: location, days: 7)
                    }
                }
            }
        }
    }
    
    // MARK: - Prayer Notification Scheduling
    
    /// Schedule notifications for prayer times
    /// - Parameters:
    ///   - location: The location for which to schedule notifications
    ///   - days: Number of days to schedule in advance (default: 1)
    func schedulePrayerNotifications(for location: LocationSuggestion, days: Int = 1) async {
        logDebug("📆 Scheduling prayer notifications for \(location.formattedLocation) for \(days) days")
        
        // First, remove existing notifications to avoid duplicates
        await removeAllPendingNotifications()
        
        let today = Date()
        let calendar = Calendar.current
        
        // Schedule for each day
        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }
            
            // Get prayer times for this date
            let prayerTimes = await PrayerTimeService.shared.getPrayerTimes(for: location, on: date)
            logDebug("🕒 Found \(prayerTimes.count) prayer times for day \(dayOffset + 1)")
            
            // Schedule notifications for each prayer time
            for prayerTime in prayerTimes {
                // Convert LocalizedStringKey to String
                let prayerNameString = String(describing: prayerTime.name)
                
                // Try to match with a notification type
                let matchedType = findMatchingNotificationType(from: prayerNameString)
                
                guard let notificationType = matchedType,
                      let isEnabled = notificationSettings[notificationType],
                      isEnabled else {
                    // Skip if no matching type or notifications disabled for this type
                    if let type = matchedType {
                        logDebug("⚠️ Skipping \(prayerNameString) - notifications disabled")
                    } else {
                        logDebug("❓ Couldn't match prayer name: \(prayerNameString) to any notification type")
                    }
                    continue
                }
                
                // Check if prayer time is in the future
                if prayerTime.time > today {
                    scheduleNotification(for: prayerTime, type: notificationType)
                } else {
                    logDebug("⏭️ Skipping \(prayerNameString) - time already passed")
                }
            }
        }
        
        // Log scheduled notifications for debugging
        await listPendingNotifications()
    }
    
    private func scheduleNotification(for prayerTime: PrayerTime, type: PrayerNotificationType) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Prayer Time: \(type.rawValue)"
        content.body = "Prayer time for \(type.rawValue) is approaching in 15 minutes"
        content.sound = UNNotificationSound.default
        
        // 15 minutes reminder
        scheduleReminderNotification(
            for: prayerTime,
            type: type,
            minutesBefore: 15,
            title: "Prayer Time Soon",
            body: "It's almost time for \(type.rawValue) prayer"
        )
        
        // Also schedule at exact prayer time
        scheduleExactTimeNotification(
            for: prayerTime,
            type: type
        )
    }
    
    private func scheduleReminderNotification(
        for prayerTime: PrayerTime,
        type: PrayerNotificationType,
        minutesBefore: Int,
        title: String,
        body: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "PRAYER_REMINDER"
        
        // Add the prayer type as user info
        content.userInfo = ["prayerType": type.rawValue]
        
        // Calculate reminder time
        guard let reminderTime = Calendar.current.date(
            byAdding: .minute,
            value: -minutesBefore,
            to: prayerTime.time
        ) else {
            logDebug("❌ Failed to calculate reminder time for \(type.rawValue)")
            return
        }
        
        // Skip if reminder time is in the past
        if reminderTime <= Date() {
            logDebug("⏭️ Skipping reminder for \(type.rawValue) - reminder time already passed")
            return
        }
        
        // Create date components for the trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderTime
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "prayer-reminder-\(type.rawValue)-\(prayerTime.timeString)-\(minutesBefore)min"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { [weak self] error in
            if let error = error {
                self?.logDebug("❌ Error scheduling reminder notification for \(type.rawValue): \(error.localizedDescription)")
            } else {
                self?.logDebug("✅ Reminder notification scheduled for \(type.rawValue) at \(components.hour ?? 0):\(components.minute ?? 0) (\(minutesBefore) min before)")
            }
        }
    }
    
    private func scheduleExactTimeNotification(
        for prayerTime: PrayerTime,
        type: PrayerNotificationType
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(type.rawValue) Prayer"
        content.body = "It's time for \(type.rawValue) prayer now"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "PRAYER_TIME"
        
        // Add the prayer type as user info
        content.userInfo = ["prayerType": type.rawValue]
        
        // Skip if prayer time is in the past
        if prayerTime.time <= Date() {
            logDebug("⏭️ Skipping exact notification for \(type.rawValue) - time already passed")
            return
        }
        
        // Create date components for the trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: prayerTime.time
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "prayer-exact-\(type.rawValue)-\(prayerTime.timeString)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { [weak self] error in
            if let error = error {
                self?.logDebug("❌ Error scheduling exact notification for \(type.rawValue): \(error.localizedDescription)")
            } else {
                self?.logDebug("✅ Exact time notification scheduled for \(type.rawValue) at \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func updateNotificationSetting(for type: PrayerNotificationType, isEnabled: Bool) {
        logDebug("🔄 Updating notification setting for \(type.rawValue): \(isEnabled)")
        notificationSettings[type] = isEnabled
        
        if !isEnabled {
            removePendingNotifications(for: type)
        } else if isNotificationsAuthorized {
            Task {
                if let location = currentLocation {
                    await schedulePrayerNotifications(for: location, days: 7)
                }
            }
        }
    }
    
    private func removePendingNotifications(for type: PrayerNotificationType) {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.contains(type.rawValue) }
                .map { $0.identifier }
            
            self?.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            self?.logDebug("🗑️ Removed \(identifiersToRemove.count) notifications for \(type.rawValue)")
        }
    }
    
    func removeAllPendingNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        logDebug("🧹 All pending notifications removed")
    }
    
    func updateLocation(_ location: LocationSuggestion) {
        logDebug("📍 Location updated to \(location.formattedLocation)")
        currentLocation = location
        
        // Only schedule notifications if we have permission
        if isNotificationsAuthorized {
            Task {
                await schedulePrayerNotifications(for: location, days: 7)
            }
        } else {
            logDebug("⚠️ Can't schedule notifications - no authorization")
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Allow banners and sounds when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification response if needed
        let userInfo = response.notification.request.content.userInfo
        if let prayerType = userInfo["prayerType"] as? String {
            logDebug("👆 User interacted with notification for \(prayerType)")
        }
        
        completionHandler()
    }
    
    // MARK: - Helper Methods
    
    private func findMatchingNotificationType(from prayerName: String) -> PrayerNotificationType? {
        // Try to find a prayer type whose name is contained in the prayerName string
        return PrayerNotificationType.allCases.first { type in
            prayerName.contains(type.rawValue)
        }
    }
    
    private func listPendingNotifications() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        logDebug("📋 Pending notifications (\(requests.count) total):")
        
        for (index, request) in requests.prefix(10).enumerated() {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                let components = trigger.dateComponents
                logDebug("  \(index+1). \(request.identifier) - Scheduled for: \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
        
        if requests.count > 10 {
            logDebug("  ... and \(requests.count - 10) more")
        }
    }
    
    private func logDebug(_ message: String) {
        if debugMode {
            print("NotificationManager: \(message)")
        }
    }
    
    // MARK: - Testing Functions
    
    /// Send a test notification to verify permissions and handling
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from iSalah"
        content.sound = UNNotificationSound.default
        
        // Trigger after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
        
        notificationCenter.add(request) { [weak self] error in
            if let error = error {
                self?.logDebug("❌ Error sending test notification: \(error.localizedDescription)")
            } else {
                self?.logDebug("✅ Test notification scheduled (5 second delay)")
            }
        }
    }
}
