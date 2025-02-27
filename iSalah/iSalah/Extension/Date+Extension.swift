//
//  Date+Extension.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

extension Date {
    
    /// Converts a Gregorian date to a formatted Hijri date with traditional month names
    /// in the format "03 Rabi Al-Akhar 1446"
    func toFormattedHijri() -> String {
        let hijriCalendar = Calendar(identifier: .islamicCivil)
        let components = hijriCalendar.dateComponents([.year, .month, .day], from: self)
        
        // Get day and pad with zero if needed
        let day = components.day ?? 0
        let dayString = String(format: "%02d", day) // Ensures 2 digits with leading zero
        
        // Get year
        let year = components.year ?? 0
        
        // Get month number
        let month = components.month ?? 0
        
        // Define traditional Islamic month names
        let monthNames = [
            "Muharram",
            "Safar",
            "Rabi Al-Awwal",
            "Rabi Al-Akhar",
            "Jumada Al-Awwal",
            "Jumada Al-Akhar",
            "Rajab",
            "Shaban",
            "Ramadan",
            "Shawwal",
            "Dhu Al-Qadah",
            "Dhu Al-Hijjah"
        ]
        
        // Get month name (with safety bounds check)
        let monthName = monthNames[max(0, min(month - 1, monthNames.count - 1))]
        
        // Combine all parts into the desired format
        return "\(dayString) \(monthName) \(year)"
    }
}

// Usage example:
// let today = Date()
// let hijriDate = today.toFormattedHijri() // e.g. "03 Rabi Al-Akhar 1446"
