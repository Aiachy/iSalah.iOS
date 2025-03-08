//
//  PrayerTime.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct PrayerTime: Identifiable, Equatable {
    let id = UUID()
    let name: LocalizedStringKey
    let time: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var isPassed: Bool {
        // Fixes the issue by comparing with the current time
        // at the moment the property is accessed
        let currentTime = Date()
        return currentTime > time
    }
    
    // For equality check
    static func == (lhs: PrayerTime, rhs: PrayerTime) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.time == rhs.time
    }
}
