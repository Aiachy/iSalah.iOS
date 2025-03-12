//
//  ClockServiceManager.swift
//  iSalah
//
//  Created on 13.03.2025.
//

import SwiftUI
import Combine

class ClockServiceManager: ObservableObject {
    // Published properties that the view will observe
    @Published var hours: String = "00"
    @Published var minutes: String = "00"
    @Published var seconds: String = "00"
    @Published var nextPrayerName: String = ""
    
    private var timer: Timer?
    
    func startTimer(for location: LocationSuggestion?) {
        // Stop any existing timer first
        stopTimer()
        
        guard let location = location else {
            print("ClockServiceManager: Location is nil, timer not started")
            return
        }
        
        print("ClockServiceManager: Starting timer for location: \(location.formattedLocation)")
        
        // Use the PrayerTimeService to create a timer that updates our published properties
        timer = PrayerTimeService.shared.startRemainingTimeTimer(
            for: location,
            updateInterval: 1.0  // Update every second
        ) { [weak self] prayerName, hrs, mins, secs in
            guard let self = self else { return }
            
            // Update on the main thread since we're changing published properties
            DispatchQueue.main.async {
                self.nextPrayerName = prayerName
                self.hours = hrs
                self.minutes = mins
                self.seconds = secs
            }
        }
        
        // Ensure the timer runs in common run loop mode (for smooth scrolling)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        print("ClockServiceManager: deinit")
        stopTimer()
    }
}
