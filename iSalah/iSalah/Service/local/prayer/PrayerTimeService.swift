//
//  PrayerTimeService.swift
//  iSalah
//
//  Updated on 07.03.2025.
//

import SwiftUI
import CoreLocation

class PrayerTimeService {
    
    static let shared = PrayerTimeService()
    
    enum CalculationMethod {
        case turkey
        case northAmerica
        case muslimWorldLeague
        case egyptian
        case ummAlQura
        case dubai
        case qatar
        case kuwait
        case singapore
        case custom(fajrAngle: Double, ishaAngle: Double)
    }
    
    private var calculationMethod: CalculationMethod = .turkey
    private var prayerTimesCache: [String: [PrayerTime]] = [:]
    
    private init() {}
    
    func getPrayerTimes(for location: LocationSuggestion, on date: Date = Date()) async -> [PrayerTime] {
        let cacheKey = generateCacheKey(location: location, date: date)
        
        if let cachedTimes = prayerTimesCache[cacheKey] {
            return cachedTimes
        }
        
        let calculatedTimes = calculatePrayerTimes(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            date: date,
            timezone: TimeZone.current
        )
        
        prayerTimesCache[cacheKey] = calculatedTimes
        printPrayerTimes(calculatedTimes, location: location, date: date)
        
        return calculatedTimes
    }
    
    func getNextDayPrayerTimes(for location: LocationSuggestion) async -> [PrayerTime] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return await getPrayerTimes(for: location, on: tomorrow)
    }
    
    func getNextPrayerTimeInfo(for location: LocationSuggestion?) async -> (name: LocalizedStringKey, time: String)? {
        guard let location else {
            return nil
        }
         
        let prayerTimes = await getPrayerTimes(for: location)
        let now = Date()
        
        if let nextPrayer = prayerTimes.first(where: { $0.time > now }) {
            return (name: nextPrayer.name, time: nextPrayer.timeString)
        } else {
            let nextDayPrayerTimes = await getNextDayPrayerTimes(for: location)
            if let firstPrayer = nextDayPrayerTimes.first {
                return (name: firstPrayer.name, time: firstPrayer.timeString)
            }
        }
         
        return nil
    }
    
    func getRemainingTimeUntilNextPrayer(for location: LocationSuggestion) async -> (nextPrayerName: String, hours: Int, minutes: Int, seconds: Int, formattedTime: String)? {
        let prayerTimes = await getPrayerTimes(for: location)
        let now = Date()
         
        if let nextPrayer = prayerTimes.first(where: { $0.time > now }) {
            let timeInterval = nextPrayer.time.timeIntervalSince(now)
            let totalSeconds = Int(timeInterval)
             
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
             
            let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
             
            return (
                nextPrayerName: String(describing: nextPrayer.name),
                hours: hours,
                minutes: minutes,
                seconds: seconds,
                formattedTime: formattedTime
            )
        } else {
            let nextDayPrayerTimes = await getNextDayPrayerTimes(for: location)
             
            if let firstPrayer = nextDayPrayerTimes.first {
                let timeInterval = firstPrayer.time.timeIntervalSince(now)
                let totalSeconds = Int(timeInterval)
                 
                let hours = totalSeconds / 3600
                let minutes = (totalSeconds % 3600) / 60
                let seconds = totalSeconds % 60
                 
                let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                 
                return (
                    nextPrayerName: String(describing: firstPrayer.name),
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds,
                    formattedTime: formattedTime
                )
            }
        }
         
        return nil
    }
     
    func startRemainingTimeTimer(for location: LocationSuggestion, updateInterval: TimeInterval = 1.0, onUpdate: @escaping (String, String, String, String) -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
             
            Task {
                if let (nextPrayerName, hours, minutes, seconds, _) = await self.getRemainingTimeUntilNextPrayer(for: location) {
                    let hoursStr = String(format: "%02d", hours)
                    let minutesStr = String(format: "%02d", minutes)
                    let secondsStr = String(format: "%02d", seconds)
                     
                    DispatchQueue.main.async {
                        onUpdate(nextPrayerName, hoursStr, minutesStr, secondsStr)
                    }
                } else {
                    DispatchQueue.main.async {
                        onUpdate("", "00", "00", "00")
                    }
                }
            }
        }
        
        // Ensure the timer runs even when scrolling
        RunLoop.main.add(timer, forMode: .common)
        
        return timer
    }
    
    private func calculatePrayerTimes(
        latitude: Double,
        longitude: Double,
        date: Date,
        timezone: TimeZone
    ) -> [PrayerTime] {
        let julianDate = calculateJulianDate(from: date)
        let dayOfYear = getDayOfYear(from: date)
        let sunCoordinates = calculateSunPosition(julianDate: julianDate)
        let timeZoneOffset = Double(timezone.secondsFromGMT(for: date)) / 3600.0
        
        let (fajrAngle, ishaAngle) = getMethodAngles(for: calculationMethod)
        
        // Calculate standard times
        let noon = calculateNoon(julianDate: julianDate, longitude: longitude, timeZoneOffset: timeZoneOffset)
        let sunTimes = calculateSunriseSunset(
            julianDate: julianDate,
            latitude: latitude,
            longitude: longitude,
            timeZoneOffset: timeZoneOffset,
            sunDeclination: sunCoordinates.declination,
            equationOfTime: sunCoordinates.equationOfTime
        )
        
        let sunrise = sunTimes.sunrise
        let sunset = sunTimes.sunset
        
        let fajr = calculateAngleTime(
            angle: fajrAngle,
            latitude: latitude,
            declination: sunCoordinates.declination,
            noon: noon,
            isAfternoon: false
        )
        
        let dhuhr = noon + (5.0 / 60.0) // 5 minutes after astronomical noon
        
        let isha = calculateAngleTime(
            angle: ishaAngle,
            latitude: latitude,
            declination: sunCoordinates.declination,
            noon: noon,
            isAfternoon: true
        )
        
        // Special calculation for Asr based on Diyanet method
        // Asr time varies based on season - we'll adjust based on shadow length method
        // and then apply seasonal adjustments to match Diyanet practice
        var asrTime: Double
        
        if isWinterSeason(dayOfYear: dayOfYear) {
            // Winter: Asr is about 1.5 hours before sunset
            asrTime = sunset - 1.5
        } else {
            // Summer: Asr is about 1.7 hours before sunset
            asrTime = sunset - 1.7
        }
        
        // Adjust times according to Diyanet practice
        let fajrTime = fajr
        let sunriseTime = sunrise - (1.0 / 60.0) // 1 minute earlier
        let dhuhrTime = dhuhr
        let maghribTime = sunset
        let ishaTime = isha
        
        // Convert to Date objects
        let calendar = Calendar.current
        var prayerTimes = [PrayerTime]()
        
        // Prayer times in order
        let times = [
            ("Fajr", fajrTime),
            ("Sunrise", sunriseTime),
            ("Dhuhr", dhuhrTime),
            ("Asr", asrTime),
            ("Maghrib", maghribTime),
            ("Isha", ishaTime)
        ]
        
        for (name, time) in times {
            if let date = timeToDate(time: time, date: date, calendar: calendar) {
                prayerTimes.append(PrayerTime(name: LocalizedStringKey(name), time: date))
            }
        }
        
        return prayerTimes.sorted { $0.time < $1.time }
    }
    
    private func calculateSunPosition(julianDate: Double) -> (declination: Double, equationOfTime: Double) {
        // Julian centuries since J2000.0
        let t = (julianDate - 2451545.0) / 36525.0
        
        // Mean longitude of the sun
        let l0 = 280.46607 + 36000.76983 * t + 0.0003032 * t * t
        let meanLongitude = normalizeAngle(l0)
        
        // Mean anomaly of the sun
        let meanAnomaly = 357.52911 + 35999.05029 * t - 0.0001537 * t * t
        
        // Equation of center
        let equationOfCenter = sin(degToRad(meanAnomaly)) * (1.914602 - 0.004817 * t - 0.000014 * t * t)
            + sin(degToRad(2 * meanAnomaly)) * (0.019993 - 0.000101 * t)
            + sin(degToRad(3 * meanAnomaly)) * 0.000289
        
        // True longitude of the sun
        let trueLongitude = meanLongitude + equationOfCenter
        
        // Obliquity of the ecliptic
        let obliquity = 23.439291 - 0.0130042 * t - 0.00000164 * t * t + 0.000000503 * t * t * t
        
        // Right ascension
        let rightAscension = radToDeg(atan2(
            cos(degToRad(obliquity)) * sin(degToRad(trueLongitude)),
            cos(degToRad(trueLongitude))
        ))
        
        // Declination
        let declination = radToDeg(asin(sin(degToRad(obliquity)) * sin(degToRad(trueLongitude))))
        
        // Equation of time (in minutes)
        let equationOfTime = 4 * (meanLongitude - normalizeAngle(rightAscension))
        
        return (declination: declination, equationOfTime: equationOfTime)
    }
    
    private func calculateNoon(julianDate: Double, longitude: Double, timeZoneOffset: Double) -> Double {
        let sunPosition = calculateSunPosition(julianDate: julianDate)
        let eqt = sunPosition.equationOfTime
        let noon = 12.0 + ((timeZoneOffset * 15.0 - longitude) / 15.0) - (eqt / 60.0)
        return noon
    }
    
    private func calculateSunriseSunset(
        julianDate: Double,
        latitude: Double,
        longitude: Double,
        timeZoneOffset: Double,
        sunDeclination: Double,
        equationOfTime: Double
    ) -> (sunrise: Double, sunset: Double) {
        let noon = 12.0 + ((timeZoneOffset * 15.0 - longitude) / 15.0) - (equationOfTime / 60.0)
        
        // Calculate hour angle for sunrise/sunset (sun at 0.833 degrees below horizon)
        let hourAngle = calculateHourAngle(latitude: latitude, declination: sunDeclination, angle: 0.833)
        
        if hourAngle.isNaN {
            // For extreme latitudes where sun doesn't rise/set
            return (sunrise: noon - 6, sunset: noon + 6) // Use approximation
        }
        
        let sunrise = noon - (hourAngle / 15.0)
        let sunset = noon + (hourAngle / 15.0)
        
        return (sunrise: sunrise, sunset: sunset)
    }
    
    private func calculateAngleTime(
        angle: Double,
        latitude: Double,
        declination: Double,
        noon: Double,
        isAfternoon: Bool
    ) -> Double {
        let hourAngle = calculateHourAngle(latitude: latitude, declination: declination, angle: angle)
        
        if hourAngle.isNaN {
            // For extreme latitudes where calculation fails
            let defaultOffset = angle / 15.0 // Approximation
            return isAfternoon ? noon + defaultOffset : noon - defaultOffset
        }
        
        return isAfternoon ? noon + (hourAngle / 15.0) : noon - (hourAngle / 15.0)
    }
    
    private func calculateHourAngle(latitude: Double, declination: Double, angle: Double) -> Double {
        let latitudeRad = degToRad(latitude)
        let declinationRad = degToRad(declination)
        let angleRad = degToRad(angle)
        
        let cosHourAngle = (sin(angleRad) - sin(latitudeRad) * sin(declinationRad)) /
                           (cos(latitudeRad) * cos(declinationRad))
        
        // Check for no sunrise/sunset at extreme latitudes
        if cosHourAngle > 1 || cosHourAngle < -1 {
            return Double.nan
        }
        
        return radToDeg(acos(cosHourAngle))
    }
    
    private func getMethodAngles(for method: CalculationMethod) -> (fajrAngle: Double, ishaAngle: Double) {
        switch method {
            case .turkey:
                return (18.0, 17.0)
            case .northAmerica:
                return (15.0, 15.0)
            case .muslimWorldLeague:
                return (18.0, 17.0)
            case .egyptian:
                return (19.5, 17.5)
            case .ummAlQura:
                return (18.5, 90.0) // 90 minutes after Maghrib for Isha
            case .dubai:
                return (18.2, 18.2)
            case .qatar:
                return (18.0, 18.0)
            case .kuwait:
                return (18.0, 17.5)
            case .singapore:
                return (20.0, 18.0)
            case .custom(let fajrAngle, let ishaAngle):
                return (fajrAngle, ishaAngle)
        }
    }
    
    private func calculateJulianDate(from date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let year = Double(components.year ?? 2000)
        let month = Double(components.month ?? 1)
        let day = Double(components.day ?? 1)
        
        var hours = Double(components.hour ?? 0)
        hours += Double(components.minute ?? 0) / 60.0
        hours += Double(components.second ?? 0) / 3600.0
        
        // Break down the Julian date calculation into smaller steps to avoid compiler error
        var a: Double = 0
        var y: Double = 0
        var m: Double = 0
        
        if month <= 2 {
            y = year - 1
            m = month + 12
        } else {
            y = year
            m = month
        }
        
        // Calculate the Julian Day Number
        a = Double(Int(y / 100.0))
        let b = 2 - a + Double(Int(a / 4.0))
        
        let julianDay = Double(Int(365.25 * (y + 4716))) +
                        Double(Int(30.6001 * (m + 1))) +
                        day +
                        b - 1524.5
        
        // Add the time of day
        let julianDate = julianDay + (hours / 24.0)
        
        return julianDate
    }
    
    private func timeToDate(time: Double, date: Date, calendar: Calendar) -> Date? {
        // Handle day boundary issues
        var adjustedTime = time
        var dayOffset = 0
        
        while adjustedTime < 0 {
            adjustedTime += 24
            dayOffset -= 1
        }
        
        while adjustedTime >= 24 {
            adjustedTime -= 24
            dayOffset += 1
        }
        
        // Extract hours and minutes
        let hours = Int(adjustedTime)
        let minutes = Int((adjustedTime - Double(hours)) * 60.0)
        let seconds = Int(((adjustedTime - Double(hours)) * 60.0 - Double(minutes)) * 60.0)
        
        // Create date components
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        if dayOffset != 0 {
            if let adjustedDate = calendar.date(byAdding: .day, value: dayOffset, to: date) {
                dateComponents = calendar.dateComponents([.year, .month, .day], from: adjustedDate)
            }
        }
        
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = seconds
        
        return calendar.date(from: dateComponents)
    }
    
    private func adjustTime(_ date: Date, byMinutes minutes: Int, calendar: Calendar) -> Date? {
        return calendar.date(byAdding: .minute, value: minutes, to: date)
    }
    
    private func getDayOfYear(from date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    }
    
    private func isWinterSeason(dayOfYear: Int) -> Bool {
        // Winter is roughly from October to March
        return dayOfYear < 80 || dayOfYear > 266
    }
    
    private func normalizeAngle(_ angle: Double) -> Double {
        var result = angle
        while result >= 360 {
            result -= 360
        }
        while result < 0 {
            result += 360
        }
        return result
    }
    
    private func sin(_ radians: Double) -> Double {
        return Darwin.sin(radians)
    }
    
    private func cos(_ radians: Double) -> Double {
        return Darwin.cos(radians)
    }
    
    private func tan(_ radians: Double) -> Double {
        return Darwin.tan(radians)
    }
    
    private func asin(_ value: Double) -> Double {
        return Darwin.asin(max(-1, min(1, value)))
    }
    
    private func acos(_ value: Double) -> Double {
        return Darwin.acos(max(-1, min(1, value)))
    }
    
    private func atan2(_ y: Double, _ x: Double) -> Double {
        return Darwin.atan2(y, x)
    }
    
    private func degToRad(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    private func radToDeg(_ radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    private func generateCacheKey(location: LocationSuggestion, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return "\(location.coordinate.latitude),\(location.coordinate.longitude)_\(dateString)"
    }
    
    private func printPrayerTimes(_ prayerTimes: [PrayerTime], location: LocationSuggestion, date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        print("iSalah: Prayer times for \(location.formattedLocation) on \(dateString):")
        for prayer in prayerTimes {
            print("iSalah: \(prayer.name): \(prayer.timeString)")
        }
    }
}
