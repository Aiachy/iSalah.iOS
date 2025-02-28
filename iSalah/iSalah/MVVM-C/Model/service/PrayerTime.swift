//
//  PrayerTime.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct PrayerTime: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let time: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var isPassed: Bool {
        return Date() > time
    }
}
