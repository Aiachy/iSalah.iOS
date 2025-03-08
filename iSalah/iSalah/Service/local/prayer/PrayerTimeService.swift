//
//  PrayerTimeService.swift
//  iSalah
//
//  Updated on 08.03.2025.
//

import SwiftUI
import CoreLocation

class PrayerTimeService {
    
    static let shared = PrayerTimeService()
    
    enum CalculationMethod: Int {
        case universityOfIslamicSciencesKarachi = 1
        case islamicSocietyOfNorthAmerica = 2
        case muslimWorldLeague = 3
        case umQuraUniversityMakkah = 4
        case egyptianGeneralAuthorityOfSurvey = 5
        case institutOfGeophysicsUniversityOfTehran = 7
        case gulfRegion = 8
        case kuwait = 9
        case qatar = 10
        case majorityOfWorldMuslims = 11
        case turkey = 13
        
        var displayName: String {
            switch self {
            case .universityOfIslamicSciencesKarachi:
                return "University of Islamic Sciences, Karachi"
            case .islamicSocietyOfNorthAmerica:
                return "Islamic Society of North America"
            case .muslimWorldLeague:
                return "Muslim World League"
            case .umQuraUniversityMakkah:
                return "Umm Al-Qura University, Makkah"
            case .egyptianGeneralAuthorityOfSurvey:
                return "Egyptian General Authority of Survey"
            case .institutOfGeophysicsUniversityOfTehran:
                return "Institute of Geophysics, University of Tehran"
            case .gulfRegion:
                return "Gulf Region"
            case .kuwait:
                return "Kuwait"
            case .qatar:
                return "Qatar"
            case .majorityOfWorldMuslims:
                return "Majority of World Muslims"
            case .turkey:
                return "Turkey (Diyanet)"
            }
        }
    }
    
    private var currentMethod: CalculationMethod = .muslimWorldLeague
    private var prayerTimesCache: [String: [PrayerTime]] = [:]
    private let cacheLock = NSLock() // For thread safety
    
    private let baseURL = "https://api.aladhan.com/v1"
    
    private init() {}
    
    func setCalculationMethod(_ method: CalculationMethod) {
        currentMethod = method
        // Clear cache when method changes
        cacheLock.lock()
        prayerTimesCache.removeAll()
        cacheLock.unlock()
    }
    
    func getPrayerTimes(for location: LocationSuggestion, on date: Date = Date()) async -> [PrayerTime] {
        let cacheKey = generateCacheKey(location: location, date: date)
        
        // Thread-safe cache check
        cacheLock.lock()
        if let cachedTimes = prayerTimesCache[cacheKey] {
            cacheLock.unlock()
            return cachedTimes
        }
        cacheLock.unlock()
        
        do {
            // Fetch prayer times from Aladhan API
            let prayerTimes = try await fetchPrayerTimesFromAladhan(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                date: date
            )
            
            if prayerTimes.isEmpty {
                print("iSalah: No prayer times returned from API, falling back to calculation")
                throw NSError(domain: "iSalah", code: 404, userInfo: [NSLocalizedDescriptionKey: "Empty prayer times list"])
            }
            
            // Thread-safe cache update
            cacheLock.lock()
            prayerTimesCache[cacheKey] = prayerTimes
            cacheLock.unlock()
            
            printPrayerTimes(prayerTimes, location: location, date: date)
            
            return prayerTimes
        } catch {
            print("iSalah: Error fetching prayer times: \(error.localizedDescription)")
            
            // Fallback to calculation method if API fails
            let calculatedTimes = calculatePrayerTimes(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                date: date,
                timezone: TimeZone.current
            )
            
            print("iSalah: Successfully calculated fallback prayer times")
            
            // Thread-safe cache update
            cacheLock.lock()
            prayerTimesCache[cacheKey] = calculatedTimes
            cacheLock.unlock()
            
            return calculatedTimes
        }
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
    
    // MARK: - Aladhan API Methods
    
    private func fetchPrayerTimesFromAladhan(
        latitude: Double,
        longitude: Double,
        date: Date
    ) async throws -> [PrayerTime] {
        // Format the date for API request (DD-MM-YYYY)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: date)
        
        // Get the timezone string
        let timeZone = TimeZone.current
        let timeZoneIdentifier = timeZone.identifier
        
        // Build the URL with parameters
        var urlComponents = URLComponents(string: "\(baseURL)/timings/\(dateString)")
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "method", value: String(currentMethod.rawValue)),
            URLQueryItem(name: "timezonestring", value: timeZoneIdentifier),
            // Add fine-tuning parameters if needed
            // URLQueryItem(name: "tune", value: "0,0,0,0,0,0,0,0,0"), // Adjust prayer times in minutes
        ]
        
        guard let url = urlComponents?.url else {
            throw NSError(domain: "iSalah", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        print("iSalah: Fetching prayer times from Aladhan API: \(url.absoluteString)")
        
        // Create and configure URL request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Make API request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "iSalah", code: (response as? HTTPURLResponse)?.statusCode ?? 500,
                          userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
        
        // Parse the response
        return try parsePrayerTimesResponse(data: data, date: date)
    }
    struct AladhanResponse: Decodable {
        let code: Int
        let status: String
        let data: TimingsData
        
        struct TimingsData: Decodable {
            let timings: Timings
            let date: DateInfo
            let meta: Meta
            
            struct Timings: Decodable {
                let Fajr: String
                let Sunrise: String
                let Dhuhr: String
                let Asr: String
                let Sunset: String
                let Maghrib: String
                let Isha: String
                let Imsak: String
                let Midnight: String
                let Firstthird: String?
                let Lastthird: String?
            }
            
            struct DateInfo: Decodable {
                let readable: String
                let timestamp: String
                let gregorian: GregorianDate
                let hijri: HijriDate
                
                struct GregorianDate: Decodable {
                    let date: String
                    let format: String
                    let day: String
                    let weekday: Weekday
                    let month: Month
                    let year: String
                    let designation: Designation
                    
                    struct Weekday: Decodable {
                        let en: String
                    }
                    
                    struct Month: Decodable {
                        let number: Int
                        let en: String
                    }
                    
                    struct Designation: Decodable {
                        let abbreviated: String
                        let expanded: String
                    }
                }
                
                struct HijriDate: Decodable {
                    let date: String
                    let format: String
                    let day: String
                    let weekday: Weekday
                    let month: Month
                    let year: String
                    let designation: Designation
                    let holidays: [String]?
                    
                    struct Weekday: Decodable {
                        let en: String
                        let ar: String
                    }
                    
                    struct Month: Decodable {
                        let number: Int
                        let en: String
                        let ar: String
                    }
                    
                    struct Designation: Decodable {
                        let abbreviated: String
                        let expanded: String
                    }
                }
            }
            
            struct Meta: Decodable {
                let latitude: Double
                let longitude: Double
                let timezone: String
                let method: Method
                let latitudeAdjustmentMethod: String
                let midnightMode: String
                let school: String
                let offset: Offset?
                
                struct Method: Decodable {
                    let id: Int
                    let name: String
                    let params: Params
                    
                    struct Params: Decodable {
                        let Fajr: Double
                        let Isha: Double
                    }
                }
                
                struct Offset: Decodable {
                    let Imsak: Int
                    let Fajr: Int
                    let Sunrise: Int
                    let Dhuhr: Int
                    let Asr: Int
                    let Maghrib: Int
                    let Sunset: Int
                    let Isha: Int
                    let Midnight: Int
                }
            }
        }
    }
    private func parsePrayerTimesResponse(data: Data, date: Date) throws -> [PrayerTime] {
        // Define the expected response structure
        
        
        do {
            let response = try JSONDecoder().decode(AladhanResponse.self, from: data)
            
            // Check if response is successful
            if response.code != 200 || response.status != "OK" {
                throw NSError(domain: "iSalah", code: response.code, userInfo: [NSLocalizedDescriptionKey: "API returned error: \(response.status)"])
            }
            
            // Convert the timings to PrayerTime objects
            let timings = response.data.timings
            let prayerTimes = createPrayerTimes(from: timings, on: date)
            
            return prayerTimes.sorted { $0.time < $1.time }
        } catch {
            print("iSalah: Error parsing Aladhan API response: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func createPrayerTimes(from timings: AladhanResponse.TimingsData.Timings, on date: Date) -> [PrayerTime] {
        let calendar = Calendar.current
        var prayerTimes: [PrayerTime] = []
        
        // Helper function to convert time string to Date
        func createTime(for timeString: String, name: String) -> PrayerTime? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            guard let parsedTime = dateFormatter.date(from: timeString) else {
                print("iSalah: Failed to parse time string: \(timeString)")
                return nil
            }
            
            // Extract hours and minutes from parsed time
            let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
            
            // Create date components from original date and add time components
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.second = 0
            
            guard let combinedDate = calendar.date(from: dateComponents) else { return nil }
            
            return PrayerTime(name: LocalizedStringKey(name), time: combinedDate)
        }
        
        // Create PrayerTime objects for each prayer time
        if let fajr = createTime(for: timings.Fajr, name: "Fajr") {
            prayerTimes.append(fajr)
        }
        
        if let sunrise = createTime(for: timings.Sunrise, name: "Sunrise") {
            prayerTimes.append(sunrise)
        }
        
        if let dhuhr = createTime(for: timings.Dhuhr, name: "Dhuhr") {
            prayerTimes.append(dhuhr)
        }
        
        if let asr = createTime(for: timings.Asr, name: "Asr") {
            prayerTimes.append(asr)
        }
        
        if let maghrib = createTime(for: timings.Maghrib, name: "Maghrib") {
            prayerTimes.append(maghrib)
        }
        
        if let isha = createTime(for: timings.Isha, name: "Isha") {
            prayerTimes.append(isha)
        }
        
        return prayerTimes
    }
    
    // MARK: - Fallback calculation methods
    
    // Keeping the original calculation methods as fallback
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
        
        // Get angles based on current calculation method
        let (fajrAngle, ishaAngle) = getMethodAngles(for: currentMethod)
        
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
        
        // Special calculation for Asr based on method
        var asrTime: Double
        
        if isWinterSeason(dayOfYear: dayOfYear) {
            // Winter: Asr is about 1.5 hours before sunset
            asrTime = sunset - 1.5
        } else {
            // Summer: Asr is about 1.7 hours before sunset
            asrTime = sunset - 1.7
        }
        
        // Adjust times according to calculation method
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
    
    private func getMethodAngles(for method: CalculationMethod) -> (fajrAngle: Double, ishaAngle: Double) {
        switch method {
        case .universityOfIslamicSciencesKarachi:
            return (18.0, 18.0)
        case .islamicSocietyOfNorthAmerica:
            return (15.0, 15.0)
        case .muslimWorldLeague:
            return (18.0, 17.0)
        case .umQuraUniversityMakkah:
            return (18.5, 90.0) // 90 minutes after Maghrib for Isha
        case .egyptianGeneralAuthorityOfSurvey:
            return (19.5, 17.5)
        case .institutOfGeophysicsUniversityOfTehran:
            return (17.7, 14.0)
        case .gulfRegion:
            return (19.5, 90.0) // 90 minutes after Maghrib for Isha
        case .kuwait:
            return (18.0, 17.5)
        case .qatar:
            return (18.0, 90.0) // 90 minutes after Maghrib for Isha
        case .majorityOfWorldMuslims:
            return (18.0, 17.0)
        case .turkey:
            return (18.0, 17.0)
        }
    }
    
    // MARK: - Helper methods for astronomical calculations
    
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
    
    private func calculateJulianDate(from date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let year = Double(components.year ?? 2000)
        let month = Double(components.month ?? 1)
        let day = Double(components.day ?? 1)
        
        var hours = Double(components.hour ?? 0)
        hours += Double(components.minute ?? 0) / 60.0
        hours += Double(components.second ?? 0) / 3600.0
        
        // Break down the Julian date calculation into smaller steps
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
    
    private func getDayOfYear(from date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    }
    
    private func isWinterSeason(dayOfYear: Int) -> Bool {
        // Winter is roughly from October to March
        return dayOfYear < 80 || dayOfYear > 266
    }
    
    // MARK: - Math utility functions
    
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
    
    // MARK: - Caching and utility functions
    
    private func generateCacheKey(location: LocationSuggestion, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return "\(location.coordinate.latitude),\(location.coordinate.longitude)_\(dateString)_\(currentMethod.rawValue)"
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
