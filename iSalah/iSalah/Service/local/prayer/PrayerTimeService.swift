//
//  PrayerTimeService.swift
//  iSalah
//
//  Created on 27.02.2025.
//

import Foundation
import CoreLocation

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

class PrayerTimeService {
    
    static let shared = PrayerTimeService()
    
    private init() {}
    
    func getPrayerTimes(for location: LocationSuggestion) async -> [PrayerTime] {
        // In a real app, this would make an API call to an Islamic prayer time service
        // using the coordinates from the LocationSuggestion
        
        // For demo purposes, generate some prayer times for the current day
        return await generateDemoPrayerTimes(latitude: location.coordinate.latitude, 
                                             longitude: location.coordinate.longitude)
    }
    
    private func generateDemoPrayerTimes(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async -> [PrayerTime] {
        // This is a placeholder implementation
        // In a real app, you would use proper calculation methods or API calls
        
        let calendar = Calendar.current
        let now = Date()
        var dateComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: now
        )
        
        // Prayer time names in English
        let prayerNames = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
        
        // Base hours for demo (these would normally be calculated based on location)
        let baseHours = [5, 6, 12, 15, 18, 19]
        
        // Apply a simple offset based on latitude to simulate location differences
        let latitudeOffset = Int(
            latitude / 15
        ) // Simple formula for demo purposes
        
        var prayerTimes = [PrayerTime]()
        
        for (index, name) in prayerNames.enumerated() {
            // Adjust hour based on latitude (simplified for demo)
            let adjustedHour = (baseHours[index] + latitudeOffset) % 24
            
            dateComponents.hour = adjustedHour
            dateComponents.minute = (
                index * 7
            ) % 60 // Just to have some variation
            
            if let time = calendar.date(from: dateComponents) {
                prayerTimes.append(PrayerTime(name: name, time: time))
            }
        }
        
        return prayerTimes
    }
     
    // Get the next prayer time name and time as strings
    func getNextPrayerTimeInfo(for location: LocationSuggestion?) async -> (name: String, time: String)? {
        guard let location else {
            return nil
        }
         
        let prayerTimes = await getPrayerTimes(for: location)
        let now = Date()
         
        guard let nextPrayer = prayerTimes.first(where: { $0.time > now }) else {
            return nil
        }
         
        return (name: nextPrayer.name, time: nextPrayer.timeString)
    }
    
    // Get remaining time until next prayer in hours, minutes, and seconds
     func getRemainingTimeUntilNextPrayer(for location: LocationSuggestion) async -> (nextPrayerName: String, hours: Int, minutes: Int, seconds: Int, formattedTime: String)? {
         let prayerTimes = await getPrayerTimes(for: location)
         let now = Date()
         
         guard let nextPrayer = prayerTimes.first(where: { $0.time > now }) else {
             return nil
         }
         
         let timeInterval = nextPrayer.time.timeIntervalSince(now)
         let totalSeconds = Int(timeInterval)
         
         let hours = totalSeconds / 3600
         let minutes = (totalSeconds % 3600) / 60
         let seconds = totalSeconds % 60
         
         // Create formatted string (e.g., "02:45:30")
         let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
         
         return (
             nextPrayerName: nextPrayer.name,
             hours: hours,
             minutes: minutes,
             seconds: seconds,
             formattedTime: formattedTime
         )
     }
     
     // Timer function that provides continuous updates of the remaining time
     func startRemainingTimeTimer(for location: LocationSuggestion, updateInterval: TimeInterval = 1.0, onUpdate: @escaping (String, String, String, String) -> Void) -> Timer {
         // This function returns a Timer that the caller should retain
         // The caller should invalidate the timer when it's no longer needed
         
         return Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
             guard let self = self else {
                 timer.invalidate()
                 return
             }
             
             Task {
                 if let (nextPrayerName, hours, minutes, seconds, _) = await self.getRemainingTimeUntilNextPrayer(for: location) {
                     // Format each component as a string with leading zeros
                     let hoursStr = String(format: "%02d", hours)
                     let minutesStr = String(format: "%02d", minutes)
                     let secondsStr = String(format: "%02d", seconds)
                     
                     // Execute callback on main thread
                     DispatchQueue.main.async {
                         onUpdate(nextPrayerName, hoursStr, minutesStr, secondsStr)
                     }
                 } else {
                     // No next prayer found, perhaps it's after the last prayer of the day
                     DispatchQueue.main.async {
                         onUpdate("", "00", "00", "00")
                     }
                 }
             }
         }
     }
    
}
