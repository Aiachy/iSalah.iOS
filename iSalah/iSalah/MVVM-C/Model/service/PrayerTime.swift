//
//  PrayerTime.swift
//  iSalah
//
//  Created on 27.02.2025.
//

import Foundation

struct PrayerTime: Identifiable {
    let id = UUID()
    let name: String
    let time: Date
    
    // Formatted time string (e.g., "05:30 AM")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    // Formatted time with AM/PM
    var timeStringWithAMPM: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: time)
    }
    
    // Check if this prayer time has passed
    var isPassed: Bool {
        return time < Date()
    }
    
    // Minutes until this prayer time
    var minutesUntil: Int {
        let interval = time.timeIntervalSince(Date())
        return max(0, Int(interval / 60))
    }
    
    // Time remaining until prayer (formatted)
    var timeRemaining: String {
        let interval = time.timeIntervalSince(Date())
        if interval <= 0 {
            return "Geçti"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) saat \(minutes) dk"
        } else {
            return "\(minutes) dk"
        }
    }
    
    // Returns the prayer name in different languages
    func localizedName(language: String = Locale.current.identifier) -> String {
        // Turkish names
        let turkishNames: [String: String] = [
            "Fajr": "İmsak",
            "Sunrise": "Güneş",
            "Dhuhr": "Öğle",
            "Asr": "İkindi",
            "Maghrib": "Akşam",
            "Isha": "Yatsı"
        ]
        
        // Arabic names
        let arabicNames: [String: String] = [
            "Fajr": "الفجر",
            "Sunrise": "الشروق",
            "Dhuhr": "الظهر",
            "Asr": "العصر",
            "Maghrib": "المغرب",
            "Isha": "العشاء"
        ]
        
        // Check if the language code starts with "tr" (Turkish)
        if language.hasPrefix("tr") {
            return turkishNames[name] ?? name
        }
        // Check if the language code starts with "ar" (Arabic)
        else if language.hasPrefix("ar") {
            return arabicNames[name] ?? name
        }
        
        // Default to English
        return name
    }
}

// Extension for array of prayer times
extension Array where Element == PrayerTime {
    // Get the next prayer time
    var nextPrayer: PrayerTime? {
        return self.first { !$0.isPassed }
    }
    
    // Get the current prayer period (between which prayers we are)
    var currentPeriod: (from: PrayerTime, to: PrayerTime)? {
        guard let nextIdx = self.firstIndex(where: { !$0.isPassed }),
              nextIdx > 0 else { return nil }
        
        return (self[nextIdx-1], self[nextIdx])
    }
}
