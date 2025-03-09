//
//  Date+Extension.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

extension Date {
    
    func toFormatted(_ format: String = "dd MMMM yyyy, EE") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = format
           
        return formatter.string(from: self)
    }
    
    func toFormattedHijri() -> String {
        let hijriCalendar = Calendar(identifier: .islamicCivil)
        let components = hijriCalendar.dateComponents(
            [.year, .month, .day],
            from: self
        )
        
        let day = components.day ?? 0
        let dayString = String(
            format: "%02d",
            day
        )
        
        let year = components.year ?? 0
        let month = components.month ?? 0
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
        
        let monthName = monthNames[max(0, min(month - 1, monthNames.count - 1))]
        return "\(dayString) \(monthName) \(year)"
    }
}

extension Date {
    func daysUntil(_ futureDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: futureDate)
        let startOfFuture = calendar.startOfDay(for: self)

        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfFuture)
        return components.day ?? 0
    }
}
