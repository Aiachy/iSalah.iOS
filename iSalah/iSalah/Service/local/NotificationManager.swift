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
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        
        for type in PrayerNotificationType.allCases {
            notificationSettings[type] = true
        }
        
        notificationCenter.delegate = self
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    func schedulePrayerNotifications(for location: LocationSuggestion) async {
        await removeAllPendingNotifications()
        
        let prayerTimes = await PrayerTimeService.shared.getPrayerTimes(for: location)
        
        for prayerTime in prayerTimes {
            let prayerName = String(describing: prayerTime.name)
            
            guard let notificationType = PrayerNotificationType.allCases.first(where: { prayerName.contains($0.rawValue) }),
                  let isEnabled = notificationSettings[notificationType], isEnabled else {
                continue
            }
            
            if prayerTime.time > Date() {
                scheduleNotification(for: prayerTime)
            }
        }
    }
    
    private func scheduleNotification(for prayerTime: PrayerTime) {
        let content = UNMutableNotificationContent()
        let prayerName = String(describing: prayerTime.name)
        
        content.title = "iSalah - Prayer Time"
        content.body = "15 minutes left, don't miss the prayer"
        content.sound = UNNotificationSound.default
        
        // Calculate time 15 minutes before prayer time
        let reminderTime = Calendar.current.date(byAdding: .minute, value: -15, to: prayerTime.time) ?? prayerTime.time
        
        // Create calendar components for the reminder time
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "prayer-\(prayerName)-\(prayerTime.timeString)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(prayerName): \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(prayerName) at \(prayerTime.timeString)")
            }
        }
    }
    
    func updateNotificationSetting(for type: PrayerNotificationType, isEnabled: Bool) {
        notificationSettings[type] = isEnabled
        
        if !isEnabled {
            removePendingNotifications(for: type)
        } else {
            Task {
                if let location = currentLocation {
                    await schedulePrayerNotifications(for: location)
                }
            }
        }
    }
    
    private func removePendingNotifications(for type: PrayerNotificationType) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.contains(type.rawValue) }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            print("Removed \(identifiersToRemove.count) notifications for \(type.rawValue)")
        }
    }
    
    private func removeAllPendingNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        print("All pending notifications removed")
    }
    
    private var currentLocation: LocationSuggestion?
    
    func updateLocation(_ location: LocationSuggestion) {
        currentLocation = location
        
        Task {
            await schedulePrayerNotifications(for: location)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

// MARK: - Daily Notification Scheduling
extension NotificationManager {
    func scheduleNextDayNotifications() {
        Task {
            if let location = currentLocation {
                await waitForMidnight()
                await schedulePrayerNotifications(for: location)
            }
        }
    }
    
    private func waitForMidnight() async {
        let calendar = Calendar.current
        let now = Date()
        
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
              let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            return
        }
        
        let timeInterval = midnight.timeIntervalSince(now)
        
        try? await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
    }
}

// MARK: - Notification Request Management
extension NotificationManager {
    func checkNotificationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    print("Notifications are not authorized")
                }
            }
        }
    }
}
