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
    
    private init() {}
    
    // Request notification permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("iSalah: Error requesting notification authorization: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }
    
    // Check if notifications are authorized
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            completion(isAuthorized)
        }
    }
    
    // Schedule notifications for all prayer times
    func schedulePrayerNotifications(for prayerTimes: [PrayerTime]) {
        print("iSalah: NotificationManager - schedulePrayerNotifications")
        
        // First remove any existing prayer notifications
        cancelAllPendingPrayerNotifications()
        
        // Schedule new notifications for each prayer time
        for prayerTime in prayerTimes {
            // Skip if the prayer time has already passed
            if prayerTime.isPassed {
                print("iSalah: Skipping notification for passed prayer time: \(prayerTime.name)")
                continue
            }
            
            // Create notification for this prayer time
            scheduleNotification(for: prayerTime)
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
        
        // Create a unique identifier for this notification
        let identifier = "iSalah.Prayer.\(prayerTime.id.uuidString)"
        
        // Create a date components trigger from the prayer time
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: prayerTime.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create the notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("iSalah: Error scheduling notification for \(prayerNameString): \(error.localizedDescription)")
            } else {
                print("iSalah: Successfully scheduled notification for \(prayerNameString) at \(prayerTime.timeString)")
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
            completion(prayerNotifications)
        }
    }
}
