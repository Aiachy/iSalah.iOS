//
//  PrayerTimesManager.swift
//  iSalah
//
//  Created by Mert Türedü on 7.03.2025.
//


import Foundation
import CoreLocation

/**
 * PrayerTimesManager
 * 
 * A comprehensive Islamic prayer times calculator that works with any coordinates worldwide.
 * Based on precise astronomical calculations and customizable parameters.
 * Updated with verification against multiple Diyanet 2025 prayer time tables.
 * Enhanced with specific optimizations for cities worldwide and improved high latitude handling.
 */
class PrayerTimesManager {
    
    // MARK: - Types
    
    /// Prayer time types
    enum PrayerTime: Int, CaseIterable {
        case fajr = 0    // imsak
        case sunrise     // güneş
        case dhuhr       // öğle
        case asr         // ikindi
        case maghrib     // akşam
        case isha        // yatsı
        
        var name: String {
            switch self {
            case .fajr: return "Fajr"
            case .sunrise: return "Sunrise"
            case .dhuhr: return "Dhuhr"
            case .asr: return "Asr"
            case .maghrib: return "Maghrib"
            case .isha: return "Isha"
            }
        }
        
        var localizedName: String {
            switch self {
            case .fajr: return "İmsak"
            case .sunrise: return "Güneş"
            case .dhuhr: return "Öğle"
            case .asr: return "İkindi"
            case .maghrib: return "Akşam"
            case .isha: return "Yatsı"
            }
        }
    }
    
    /// Calculation methods used by various organizations around the world
    enum CalculationMethod: String, CaseIterable {
        case diyanet = "Turkish Diyanet İşleri Başkanlığı"
        case muslimWorldLeague = "Muslim World League"
        case egyptian = "Egyptian General Authority of Survey"
        case ummAlQura = "Umm al-Qura University, Makkah"
        case karachi = "University of Islamic Sciences, Karachi"
        case isna = "Islamic Society of North America"
        case tehran = "Institute of Geophysics, University of Tehran"
        case kuwait = "Kuwait Ministry of Awqaf and Islamic Affairs"
        case qatar = "Qatar Ministry of Awqaf and Islamic Affairs"
        case singapore = "Islamic Religious Council of Singapore"
        case france = "Union des Organisations Islamiques de France"
        case russia = "Spiritual Administration of Muslims of Russia"
        case custom = "Custom Settings"
        
        var parameters: CalculationParameters {
            switch self {
            case .diyanet:
                return CalculationParameters(
                    fajrAngle: 18.0,
                    ishaAngle: 17.0,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .muslimWorldLeague:
                return CalculationParameters(
                    fajrAngle: 18.0,
                    ishaAngle: 17.0,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .egyptian:
                return CalculationParameters(
                    fajrAngle: 19.5,
                    ishaAngle: 17.5,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .ummAlQura:
                return CalculationParameters(
                    fajrAngle: 18.5,
                    ishaAngle: 0.0,
                    ishaInterval: 90,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .karachi:
                return CalculationParameters(
                    fajrAngle: 18.0,
                    ishaAngle: 18.0,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .isna:
                return CalculationParameters(
                    fajrAngle: 15.0,
                    ishaAngle: 15.0,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .tehran:
                return CalculationParameters(
                    fajrAngle: 17.7,
                    ishaAngle: 14.0,
                    ishaInterval: 0,
                    maghribAngle: 4.5,
                    maghribInterval: 0,
                    method: self
                )
            case .kuwait:
                return CalculationParameters(
                    fajrAngle: 18.0,
                    ishaAngle: 17.5,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .qatar:
                return CalculationParameters(
                    fajrAngle: 18.0,
                    ishaAngle: 0.0,
                    ishaInterval: 90,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .singapore:
                return CalculationParameters(
                    fajrAngle: 20.0,
                    ishaAngle: 18.0,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .france:
                return CalculationParameters(
                    fajrAngle: 12.0,
                    ishaAngle: 12.0,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .russia:
                return CalculationParameters(
                    fajrAngle: 16.0,
                    ishaAngle: 15.0,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            case .custom:
                // Default values, can be modified
                return CalculationParameters(
                    fajrAngle: 18.0,
                    ishaAngle: 17.0,
                    ishaInterval: 0,
                    maghribAngle: 1.0,
                    maghribInterval: 0,
                    method: self
                )
            }
        }
    }
    
    /// The juristic method used for Asr time calculation
    enum AsrJuristicMethod: Int, CaseIterable {
        case standard = 0    // Shafi'i, Maliki, Hanbali (shadow factor = 1)
        case hanafi = 1      // Hanafi (shadow factor = 2)
        
        var shadowFactor: Double {
            return self == .standard ? 1.0 : 2.0
        }
        
        var name: String {
            switch self {
            case .standard: return "Standard (Shafi'i, Maliki, Hanbali)"
            case .hanafi: return "Hanafi"
            }
        }
    }
    
    /// Adjustment methods for higher latitudes where prayer times may become extremely early/late
    enum HighLatitudeMethod: Int, CaseIterable {
        case none = 0            // No adjustment
        case middleOfNight = 1   // Middle of night-based adjustment
        case seventhOfNight = 2  // 1/7th of night-based adjustment
        case angleBasedMethod = 3 // Angle-based method
        case diyanetMethod = 4   // Diyanet's official method for high latitudes
        case enhancedDiyanetMethod = 5 // Enhanced Diyanet method with better seasonal adjustments
        
        var name: String {
            switch self {
            case .none: return "No Adjustment"
            case .middleOfNight: return "Middle of Night"
            case .seventhOfNight: return "One Seventh of Night"
            case .angleBasedMethod: return "Angle-Based Method"
            case .diyanetMethod: return "Diyanet Method"
            case .enhancedDiyanetMethod: return "Enhanced Diyanet Method"
            }
        }
    }
    
    /// Prayer time calculation parameters
    struct CalculationParameters {
        var fajrAngle: Double     // Angle for Fajr (degrees)
        var ishaAngle: Double     // Angle for Isha (degrees)
        var ishaInterval: Int     // Minutes after Maghrib for Isha (if angle is 0)
        var maghribAngle: Double  // Angle for Maghrib (degrees)
        var maghribInterval: Int  // Minutes after sunset for Maghrib
        let method: CalculationMethod
        
        // Time adjustments in minutes for each prayer
        var adjustments: [PrayerTime: Int] = [
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 0,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ]
        
        // Seasonal adjustments for high latitudes
        var seasonalAdjustments: [Int: [PrayerTime: Int]] = [:]
    }
    
    // MARK: - Constants
    
    private let kMidnightMode = 0 // midnight mode
    private let kJafariAngle = 16.0 // Jafari Fajr angle
    
    // Standard atmospheric refraction angle
    private let standardRefraction = 0.833
    
    // Month names (to help with debugging and validation)
    private let monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    // MARK: - Properties
    
    /// Location coordinates
    private var latitude: Double
    private var longitude: Double
    
    /// Location name (if provided)
    private var locationName: String?
    
    /// Timezone information
    private var timeZone: TimeZone
    private var timeZoneOffset: Double
    
    /// Calculation methods
    private var calculationParameters: CalculationParameters
    private var asrMethod: AsrJuristicMethod
    private var highLatMethod: HighLatitudeMethod
    
    /// Additional settings
    private var dhuhrMinutes: Int = 0  // Minutes after midday for Dhuhr
    private var isFajrAngleBasedOnLocation: Bool = true
    
    /// Enhanced city database with coordinates
    private let cityCoordinates: [String: (latitude: Double, longitude: Double)] = [
        "berlin": (52.52, 13.41),
        "athens": (37.98, 23.73),
        "hongkong": (22.32, 114.17),
        "bala": (39.68, 33.11),
        "london": (51.51, -0.13),
        "madrid": (40.42, -3.70),
        "bucharest": (44.43, 26.10),
        "bern": (46.95, 7.44),
        "tokyo": (35.69, 139.69),
        "tehran": (35.69, 51.39),
        "rome": (41.90, 12.50),
        "istanbul": (41.01, 28.97),
        "ankara": (39.93, 32.86),
        "dubai": (25.20, 55.27),
        "riyadh": (24.71, 46.67),
        "cairo": (30.04, 31.24),
        "moscow": (55.75, 37.62),
        "newyork": (40.71, -74.00),
        "losangeles": (34.05, -118.24),
        "chicago": (41.88, -87.63),
        "sydney": (33.87, 151.21),
        "melbourne": (37.81, 144.96),
        "auckland": (36.85, 174.76),
        "johannesburg": (26.20, 28.05),
        "singapore": (1.29, 103.85),
        "kualalumpur": (3.14, 101.69),
        "bangkok": (13.75, 100.50),
        "beijing": (39.90, 116.41),
        "delhi": (28.61, 77.21),
        "mumbai": (19.08, 72.88)
    ]
    
    /// DST information
    private var usesAutomaticDST: Bool = true
    private var manualDSTDates: (start: Date?, end: Date?)?
    
    // MARK: - Initialization
    
    /// Initialize the prayer times calculator with location coordinates
    /// - Parameters:
    ///   - coordinates: The geographic coordinates
    ///   - calculationMethod: The calculation method to use
    ///   - asrMethod: The juristic method for Asr
    ///   - highLatitudeMethod: The adjustment method for high latitudes
    ///   - timeZone: The time zone to use (default: system time zone)
    ///   - locationName: Optional name of the location (helps with city-specific adjustments)
    init(coordinates: CLLocationCoordinate2D,
         calculationMethod: CalculationMethod = .diyanet,
         asrMethod: AsrJuristicMethod = .standard,
         highLatitudeMethod: HighLatitudeMethod = .enhancedDiyanetMethod,
         timeZone: TimeZone = TimeZone.current,
         locationName: String? = nil) {
        
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
        self.calculationParameters = calculationMethod.parameters
        self.asrMethod = asrMethod
        self.highLatMethod = highLatitudeMethod
        self.timeZone = timeZone
        self.timeZoneOffset = Double(timeZone.secondsFromGMT(for: Date())) / 3600.0
        self.locationName = locationName?.lowercased()
        
        // Initialize seasonal adjustments
        initializeSeasonalAdjustments()
        
        // Apply location-specific optimizations
        self.optimizeForLocation()
    }
    
    // MARK: - Public Methods
    
    /// Calculate prayer times for a specific date
    /// - Parameter date: The date to calculate prayer times for
    /// - Returns: Dictionary mapping prayer times to their corresponding times
    func calculatePrayerTimes(for date: Date = Date()) -> [PrayerTime: Date] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year, let month = components.month, let day = components.day else {
            return [:]
        }
        
        // Apply any seasonal adjustments based on month
        applySeasonalAdjustments(month: month)
        
        let julianDay = calculateJulianDay(year: year, month: month, day: day)
        var prayerTimes = computePrayerTimes(julianDay: julianDay)
        
        // Adjust for DST if needed
        if isDSTActive(for: date) {
            for (prayer, time) in prayerTimes {
                prayerTimes[prayer] = time + 1.0 / 24.0 // Add one hour
            }
        }
        
        // Convert from double hours to Date objects
        var result: [PrayerTime: Date] = [:]
        
        for (prayer, time) in prayerTimes {
            if let date = convertDoubleHoursToDate(time, year: year, month: month, day: day) {
                result[prayer] = date
            }
        }
        
        return result
    }
    
    /// Set custom time adjustments for each prayer (in minutes)
    /// - Parameter adjustments: A dictionary mapping prayer times to their adjustments in minutes
    func setTimeAdjustments(_ adjustments: [PrayerTime: Int]) {
        for (prayer, minutes) in adjustments {
            calculationParameters.adjustments[prayer] = minutes
        }
    }
    
    /// Add seasonal adjustments for specific months
    /// - Parameters:
    ///   - month: Month number (1-12)
    ///   - adjustments: Adjustments for each prayer time in that month
    func addSeasonalAdjustment(month: Int, adjustments: [PrayerTime: Int]) {
        calculationParameters.seasonalAdjustments[month] = adjustments
    }
    
    /// Set a custom calculation method with specific parameters
    /// - Parameters:
    ///   - fajrAngle: The angle for Fajr calculation
    ///   - ishaAngle: The angle for Isha calculation
    ///   - ishaInterval: Minutes after Maghrib for Isha (if angle-based method is not used)
    func setCustomMethod(fajrAngle: Double, ishaAngle: Double, ishaInterval: Int = 0) {
        var customParams = CalculationMethod.custom.parameters
        customParams.adjustments = calculationParameters.adjustments
        customParams.seasonalAdjustments = calculationParameters.seasonalAdjustments
        
        calculationParameters = CalculationParameters(
            fajrAngle: fajrAngle,
            ishaAngle: ishaAngle,
            ishaInterval: ishaInterval,
            maghribAngle: customParams.maghribAngle,
            maghribInterval: customParams.maghribInterval,
            method: .custom,
            adjustments: customParams.adjustments,
            seasonalAdjustments: customParams.seasonalAdjustments
        )
    }
    
    /// Set Dhuhr minutes adjustment
    /// - Parameter minutes: Minutes to be added to mid-day for Dhuhr time
    func setDhuhrMinutes(_ minutes: Int) {
        dhuhrMinutes = minutes
    }
    
    /// Change the calculation method
    /// - Parameter method: The new calculation method to use
    func setCalculationMethod(_ method: CalculationMethod) {
        let currentAdjustments = calculationParameters.adjustments
        let currentSeasonalAdjustments = calculationParameters.seasonalAdjustments
        calculationParameters = method.parameters
        calculationParameters.adjustments = currentAdjustments
        calculationParameters.seasonalAdjustments = currentSeasonalAdjustments
        
        // Re-optimize after changing calculation method
        optimizeForLocation()
    }
    
    /// Change the Asr juristic method
    /// - Parameter method: The juristic method to use for Asr calculation
    func setAsrMethod(_ method: AsrJuristicMethod) {
        asrMethod = method
    }
    
    /// Change the high latitude adjustment method
    /// - Parameter method: The method to use for high latitude adjustments
    func setHighLatitudeMethod(_ method: HighLatitudeMethod) {
        highLatMethod = method
    }
    
    /// Set manual DST dates instead of automatic detection
    /// - Parameters:
    ///   - start: Start date of DST
    ///   - end: End date of DST
    func setManualDSTDates(start: Date, end: Date) {
        usesAutomaticDST = false
        manualDSTDates = (start, end)
    }
    
    /// Use automatic DST detection (based on system timeZone)
    func useAutomaticDST() {
        usesAutomaticDST = true
        manualDSTDates = nil
    }
    
    // MARK: - Private Calculation Methods
    
    /// Initialize seasonal adjustments for high latitudes
    private func initializeSeasonalAdjustments() {
        // Northern European cities often need seasonal adjustments
        if latitude >= 45.0 {
            // Winter adjustments (Dec-Feb)
            calculationParameters.seasonalAdjustments[12] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 0, .isha: 0]
            calculationParameters.seasonalAdjustments[1] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 0, .isha: 0]
            calculationParameters.seasonalAdjustments[2] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 0, .isha: 0]
            
            // Spring adjustments (Mar-May)
            calculationParameters.seasonalAdjustments[3] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 2, .isha: 0]
            calculationParameters.seasonalAdjustments[4] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 2, .isha: 0]
            calculationParameters.seasonalAdjustments[5] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 3, .isha: 0]
            
            // Summer adjustments (Jun-Aug)
            calculationParameters.seasonalAdjustments[6] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 3, .isha: 0]
            calculationParameters.seasonalAdjustments[7] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 3, .isha: 0]
            calculationParameters.seasonalAdjustments[8] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 3, .isha: 0]
            
            // Fall adjustments (Sep-Nov)
            calculationParameters.seasonalAdjustments[9] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 2, .isha: 0]
            calculationParameters.seasonalAdjustments[10] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 0, .isha: 0]
            calculationParameters.seasonalAdjustments[11] = [.fajr: 0, .dhuhr: 3, .asr: 0, .maghrib: 0, .isha: 0]
        }
    }
    
    /// Apply seasonal adjustments based on month
    private func applySeasonalAdjustments(month: Int) {
        if let adjustments = calculationParameters.seasonalAdjustments[month] {
            for (prayer, adjustment) in adjustments {
                calculationParameters.adjustments[prayer] = adjustment
            }
        }
    }
    
    /// Check if DST is active for a given date
    private func isDSTActive(for date: Date) -> Bool {
        if usesAutomaticDST {
            return timeZone.isDaylightSavingTime(for: date)
        } else if let dstDates = manualDSTDates,
                  let start = dstDates.start,
                  let end = dstDates.end {
            return date >= start && date <= end
        }
        return false
    }
    
    /// Calculate the Julian day for a given date
    private func calculateJulianDay(year: Int, month: Int, day: Int) -> Double {
        var jd: Double = 0
        
        // Adjust for different calendar systems
        let adjustedYear = month > 2 ? Double(year) : Double(year - 1)
        let adjustedMonth = month > 2 ? Double(month) : Double(month + 12)
        
        // Julian day calculation formula
        jd = Double(day) + ((153.0 * adjustedMonth - 457.0) / 5.0) +
             365.0 * adjustedYear + (adjustedYear / 4.0) - (adjustedYear / 100.0) +
             (adjustedYear / 400.0) + 1721118.5
        
        return jd
    }
    
    /// Calculate the time of astronomical events for prayer times
    private func computePrayerTimes(julianDay: Double) -> [PrayerTime: Double] {
        // Get sun's position
        let sunPosition = calculateSunPosition(julianDay: julianDay)
        let declination = sunPosition.declination
        let equation = sunPosition.equation
        
        // Calculate base times
        let dhuhr = computeMidDay(equation: equation)
        let sunrise = computeSunAngleTime(angle: riseSetAngle(), declination: declination, time: dhuhr, direction: .rising)
        let maghrib = computeSunAngleTime(angle: riseSetAngle(), declination: declination, time: dhuhr, direction: .setting)
        
        // Calculate Asr time
        let asr = computeAsr(declination: declination, time: dhuhr, shadowFactor: asrMethod.shadowFactor)
        
        // Calculate Fajr and Isha
        var fajr = computeSunAngleTime(angle: calculationParameters.fajrAngle, declination: declination, time: dhuhr, direction: .rising)
        
        var isha: Double
        if calculationParameters.ishaInterval > 0 {
            isha = maghrib + Double(calculationParameters.ishaInterval) / 60.0
        } else {
            isha = computeSunAngleTime(angle: calculationParameters.ishaAngle, declination: declination, time: dhuhr, direction: .setting)
        }
        
        // Handle invalid/extreme values for high latitudes
        let absoluteLatitude = abs(latitude)
        if fajr.isNaN || absoluteLatitude >= 48.0 {
            fajr = adjustForHighLatitudes(baseTime: sunrise, referenceTime: maghrib, angle: calculationParameters.fajrAngle, direction: .rising, declination: declination)
        }

        if isha.isNaN || absoluteLatitude >= 48.0 {
            isha = adjustForHighLatitudes(baseTime: maghrib, referenceTime: sunrise, angle: calculationParameters.ishaAngle, direction: .setting, declination: declination)
        }
        // Apply adjustments
        var times: [PrayerTime: Double] = [:]
            
            times[.fajr] = normalizeHours(fajr + Double(calculationParameters.adjustments[.fajr] ?? 0) / 60.0)
            times[.sunrise] = normalizeHours(sunrise + Double(calculationParameters.adjustments[.sunrise] ?? 0) / 60.0)
            times[.dhuhr] = normalizeHours(dhuhr + Double(dhuhrMinutes + (calculationParameters.adjustments[.dhuhr] ?? 0)) / 60.0)
            times[.asr] = normalizeHours(asr + Double(calculationParameters.adjustments[.asr] ?? 0) / 60.0)
            times[.maghrib] = normalizeHours(maghrib + Double(calculationParameters.adjustments[.maghrib] ?? 0) / 60.0)
            times[.isha] = normalizeHours(isha + Double(calculationParameters.adjustments[.isha] ?? 0) / 60.0)
            
            // Add longitude correction
            for prayer in PrayerTime.allCases {
                if let time = times[prayer] {
                    let correctedTime = normalizeHours(time + longitudeCorrection(time))
                    times[prayer] = correctedTime
                }
            }
        
        return times
    }
    
    /// Apply longitude correction to account for local time zone
    private func longitudeCorrection(_ time: Double) -> Double {
        // Calculate local time difference from standard meridian time
        let standardMeridian = timeZoneOffset * 15.0
        let localMeridian = longitude
        
        // Convert to hours: 15 degrees = 1 hour
        let timeDiff = (standardMeridian - localMeridian) / 15.0
        
        // Convert to fraction of day
        return timeDiff / 24.0
    }
    
    private func normalizeHours(_ hours: Double) -> Double {
        var normalized = hours
        while (normalized < 0) { normalized += 24 }
        while (normalized >= 24) { normalized -= 24 }
        return normalized
    }
    
    /// Solar position calculation for a Julian day
    private func calculateSunPosition(julianDay: Double) -> (declination: Double, equation: Double) {
        // Days since January 1, 2000 12:00 UT
        let d = julianDay - 2451545.0
        
        // Mean anomaly of the sun
        let g = fixAngle(357.529 + 0.98560028 * d)
        
        // Mean longitude of the sun
        let q = fixAngle(280.459 + 0.98564736 * d)
        
        // Sun's geocentric ecliptic longitude
        let l = fixAngle(q + 1.915 * sin(degreesToRadians(g)) + 0.020 * sin(degreesToRadians(2 * g)))
        
        // Obliquity of the ecliptic
        let e = 23.439 - 0.00000036 * d
        
        // Equation of time calculation
        let ra = radiansToDegrees(atan2(cos(degreesToRadians(e)) * sin(degreesToRadians(l)), cos(degreesToRadians(l))))
        let equationOfTime = (q / 15.0) - (fixAngle(ra) / 15.0)
        
        // Sun's declination
        let sinDec = sin(degreesToRadians(e)) * sin(degreesToRadians(l))
        let declination = radiansToDegrees(asin(sinDec))
        
        return (declination, equationOfTime)
    }
    
    /// Calculate mid-day time (when sun reaches its highest point)
    private func computeMidDay(equation: Double) -> Double {
        let noon = 12.0 - equation
        return noon
    }
    
    /// Calculate the time when sun reaches a specific angle
    private func computeSunAngleTime(angle: Double, declination: Double, time: Double, direction: SunDirection) -> Double {
        // Adjust angle for atmospheric refraction
        let adjustedAngle = (angle == standardRefraction) ? standardRefraction : angle
        
        // Convert latitude and declination to radians
        let latitudeRad = degreesToRadians(latitude)
        let declinationRad = degreesToRadians(declination)
        
        // Compute hour angle
        let cosHourAngle = (sin(degreesToRadians(-adjustedAngle)) - sin(latitudeRad) * sin(declinationRad)) / (cos(latitudeRad) * cos(declinationRad))
        
        // Check if the sun never reaches the specified angle
        if cosHourAngle > 1 || cosHourAngle < -1 {
            return Double.nan
        }
        
        // Convert hour angle to hours
        var hourAngle = radiansToDegrees(acos(cosHourAngle)) / 15.0
        
        // Adjust for direction (rising or setting)
        hourAngle = direction == .rising ? 24 - hourAngle : hourAngle
        
        // Calculate time
        return time - hourAngle
    }
    
    /// Calculate the Asr time
    private func computeAsr(declination: Double, time: Double, shadowFactor: Double) -> Double {
        let latitudeRad = degreesToRadians(latitude)
        let declinationRad = degreesToRadians(declination)
        
        // Calculate zenith distance
        let zenithDistance = acos(sin(latitudeRad) * sin(declinationRad) + cos(latitudeRad) * cos(declinationRad))
        
        // Calculate Asr shadow altitude
        let asrAltitude = atan(1.0 / (shadowFactor + tan(zenithDistance)))
        
        // Convert to hour angle and then to time
        let asrHourAngle = radiansToDegrees(asrAltitude) / 15.0
        let asrTime = time + asrHourAngle
        
        return asrTime
    }
    
    /// Direction of sun's movement
    private enum SunDirection {
        case rising
        case setting
    }
    
    /// Adjust times for locations in higher latitudes
    private func adjustForHighLatitudes(baseTime: Double, referenceTime: Double, angle: Double, direction: SunDirection, declination: Double) -> Double {
        let nightDuration = getApproximateNightDuration(baseTime: baseTime, referenceTime: referenceTime)
        let absoluteLatitude = abs(latitude)
        
        switch highLatMethod {
        case .none:
            return baseTime
        case .middleOfNight:
            return direction == .rising ? 
                baseTime - (nightDuration / 2.0) : 
                baseTime + (nightDuration / 2.0)
        case .seventhOfNight:
            return direction == .rising ? 
                baseTime - (nightDuration / 7.0) : 
                baseTime + (nightDuration / 7.0)
        case .angleBasedMethod:
            // Use proportion of the night based on angle
            let portion = angle / 60.0
            return direction == .rising ? 
                baseTime - (portion * nightDuration) : 
                baseTime + (portion * nightDuration)
        case .diyanetMethod:
               // Diyanet's method for high latitudes
               
               // For very high latitudes (northern Europe, etc.)
               if absoluteLatitude >= 55.0 {
                   // Use 1/7th of night method but with a minimum gap
                   let adjustment = max(nightDuration / 7.0, 1.0 / 24.0 * 1.5) // At least 1.5 hours
                   return direction == .rising ?
                       baseTime - adjustment :
                       baseTime + adjustment
               } else if absoluteLatitude >= 48.0 {
                   // For high latitudes, use a blend of methods
                   let angleBasedPortion = angle / 60.0
                   let nightPortion = nightDuration / 7.0
                   let adjustment = (angleBasedPortion * 0.6 + 0.4) * nightPortion
                   return direction == .rising ?
                       baseTime - adjustment :
                       baseTime + adjustment
               } else {
                   // For moderate latitudes, use standard angle-based method
                   return computeSunAngleTime(angle: angle,
                                              declination: declination,
                                              time: getMidDay(),
                                              direction: direction)
               }
        case .enhancedDiyanetMethod:
            // Enhanced method with better handling of seasonal variations
            let month = getCurrentMonth()
            
            // Summer months in northern hemisphere (May-Aug)
            if month >= 5 && month <= 8 && latitude > 0 {
                if absoluteLatitude >= 55.0 {
                    // For very high latitudes in summer
                    let adjustment = max(nightDuration / 6.0, 1.0 / 24.0 * 1.75) // At least 1.75 hours
                    return direction == .rising ? 
                        baseTime - adjustment : 
                        baseTime + adjustment
                } else if absoluteLatitude >= 48.0 {
                    // For high latitudes in summer
                    let adjustment = max(nightDuration / 7.0, 1.0 / 24.0 * 1.5) // At least 1.5 hours
                    return direction == .rising ? 
                        baseTime - adjustment : 
                        baseTime + adjustment
                }
            }
            
            // Winter months in northern hemisphere (Nov-Feb)
            else if ((month >= 11 && month <= 12) || (month >= 1 && month <= 2)) && latitude > 0 {
                // Use more standard calculation in winter
                if absoluteLatitude >= 55.0 {
                    // For very high latitudes in winter
                    let nightPortion = nightDuration / 7.0
                    return direction == .rising ? 
                        baseTime - nightPortion : 
                        baseTime + nightPortion
                }
            }
            
            // Summer months in southern hemisphere (Nov-Feb)
            else if ((month >= 11 && month <= 12) || (month >= 1 && month <= 2)) && latitude < 0 {
                if absoluteLatitude >= 55.0 {
                    // For very high latitudes in summer
                    let adjustment = max(nightDuration / 6.0, 1.0 / 24.0 * 1.75) // At least 1.75 hours
                    return direction == .rising ? 
                        baseTime - adjustment : 
                        baseTime + adjustment
                } else if absoluteLatitude >= 48.0 {
                    // For high latitudes in summer
                    let adjustment = max(nightDuration / 7.0, 1.0 / 24.0 * 1.5) // At least 1.5 hours
                    return direction == .rising ? 
                        baseTime - adjustment : 
                        baseTime + adjustment
                }
            }
            
            // Winter months in southern hemisphere (May-Aug)
            else if (month >= 5 && month <= 8) && latitude < 0 {
                // Use more standard calculation in winter
                if absoluteLatitude >= 55.0 {
                    // For very high latitudes in winter
                    let nightPortion = nightDuration / 7.0
                    return direction == .rising ? 
                        baseTime - nightPortion : 
                        baseTime + nightPortion
                }
            }
            
            // For moderate latitudes or other seasons, use a blend of methods
            let angleBasedPortion = angle / 60.0
            let nightPortion = nightDuration / 7.0
            let adjustment = (angleBasedPortion * 0.65 + 0.35) * nightPortion
            return direction == .rising ? 
                baseTime - adjustment : 
                baseTime + adjustment
        }
    }
    
    /// Get the current month
    private func getCurrentMonth() -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        return month
    }
    
    /// Get midday for the current day
    private func getMidDay() -> Double {
        let sunPosition = calculateSunPosition(julianDay: calculateJulianDay(from: Date()))
        return computeMidDay(equation: sunPosition.equation)
    }
    
    /// Calculate Julian day from a date
    private func calculateJulianDay(from date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year, let month = components.month, let day = components.day else {
            return 0
        }
        
        return calculateJulianDay(year: year, month: month, day: day)
    }
    
    /// Calculate the approximate duration of night
    private func getApproximateNightDuration(baseTime: Double, referenceTime: Double) -> Double {
        // If night crosses midnight, account for it
        if baseTime > referenceTime {
            return (24 - baseTime) + referenceTime
        } else {
            return referenceTime - baseTime
        }
    }
    
    /// Calculate the angle for sunrise/sunset
    private func riseSetAngle() -> Double {
        // Approximate altitude of the sun for sunrise/sunset
        // 0.833 degrees is standard for most calculations, accounting for refraction and solar radius
        return standardRefraction
    }
    
    /// Convert double hours to a Date object
    private func convertDoubleHoursToDate(_ hours: Double, year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        let totalHours = hours
        let hourInt = Int(totalHours)
        let minutesDecimal = (totalHours - Double(hourInt)) * 60.0
        let minuteInt = Int(minutesDecimal)
        let secondsDecimal = (minutesDecimal - Double(minuteInt)) * 60.0
        let secondInt = Int(secondsDecimal)
        
        components.hour = hourInt
        components.minute = minuteInt
        components.second = secondInt
        components.timeZone = timeZone
        
        return Calendar.current.date(from: components)
    }
    
    /// Convert Julian day to ISO date string
    private func julianDayToISO(_ julianDay: Double) -> String {
        let z = julianDay + 0.5
        let w = Int((z - 1867216.25) / 36524.25)
        let x = Int(w / 4)
        let a = Int(z) + 1 + w - x
        let b = a + 1524
        let c = Int((Double(b) - 122.1) / 365.25)
        let d = Int(365.25 * Double(c))
        let e = Int(Double((b - d)) / 30.6001)
        
        let day = b - d - Int(30.6001 * Double(e))
        let month = e <= 13 ? e - 1 : e - 13
        let year = month > 2 ? c - 4716 : c - 4715
        
        return "\(year)-\(month)-\(day)"
    }
    
    // MARK: - Helper Functions
    
    /// Optimize calculation parameters based on location
    private func optimizeForLocation() {
        let absoluteLatitude = abs(latitude)
        
        // For Diyanet method, apply location-specific optimizations
        if calculationParameters.method == .diyanet {
            // For high latitudes (beyond 45 degrees), adjust methods
            if absoluteLatitude > 45 && absoluteLatitude < 66 {
                highLatMethod = .enhancedDiyanetMethod
                
                // Increase Fajr angle for higher latitudes
                if isFajrAngleBasedOnLocation {
                    adjustFajrAngleForLocation(absoluteLatitude)
                }
                
                // For Moscow (approx. 55.7°N), apply specific time adjustments
                if absoluteLatitude > 55 && absoluteLatitude < 56 {
                    setTimeAdjustments([
                        .fajr: -5,
                        .sunrise: 0,
                        .dhuhr: 3,
                        .asr: 3,
                        .maghrib: 3,
                        .isha: 0
                    ])
                }
            }
            
            // Apply city-specific optimizations based on coordinates or name
            applyCitySpecificAdjustments()
        }
        
        // For very high latitudes (beyond 66°N - Arctic Circle)
        if absoluteLatitude >= 66 {
            highLatMethod = .enhancedDiyanetMethod
            // For extreme latitudes, we use specialized adjustments
            setTimeAdjustments([
                .fajr: 0,
                .sunrise: 0,
                .dhuhr: 2,
                .asr: 2,
                .maghrib: 2,
                .isha: 0
            ])
        }
    }
    
    /// Apply city-specific optimizations based on coordinates or location name
    private func applyCitySpecificAdjustments() {
        // Try to find city by exact name match
        if let name = locationName {
            for (cityName, _) in cityCoordinates {
                if name.contains(cityName) {
                    applyCityAdjustments(for: cityName)
                    return
                }
            }
        }
        
        // If no name match, try by coordinates
        for (cityName, coordinates) in cityCoordinates {
            if isNear(latitude: coordinates.latitude, longitude: coordinates.longitude, maxDistance: 0.5) {
                applyCityAdjustments(for: cityName)
                return
            }
        }
        
        // If no city match, apply adjustments based on latitude ranges
        applyLatitudeBasedAdjustments()
    }
    
    /// Apply city-specific adjustments by city name
    private func applyCityAdjustments(for cityName: String) {
        switch cityName {
        case "berlin":
            applyBerlinAdjustments()
        case "athens":
            applyAthensAdjustments()
        case "hongkong":
            applyHongKongAdjustments()
        case "bala":
            applyBalaAdjustments()
        case "madrid":
            applyMadridAdjustments()
        case "london":
            applyLondonAdjustments()
        case "bucharest":
            applyBucharestAdjustments()
        case "bern":
            applyBernAdjustments()
        case "tokyo":
            applyTokyoAdjustments()
        case "tehran":
            applyTehranAdjustments()
        case "rome":
            applyRomeAdjustments()
        case "istanbul":
            applyIstanbulAdjustments()
        case "ankara":
            applyAnkaraAdjustments()
        case "dubai":
            applyDubaiAdjustments()
        case "riyadh":
            applyRiyadhAdjustments()
        case "cairo":
            applyCairoAdjustments()
        case "moscow":
            applyMoscowAdjustments()
        default:
            // Default to latitude-based adjustments if specific city not found
            applyLatitudeBasedAdjustments()
        }
    }
    
    func getRawPrayerTimesForDebugging(for date: Date = Date()) -> [PrayerTime: Double] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year, let month = components.month, let day = components.day else {
            return [:]
        }
        
        // Apply any seasonal adjustments based on month
        applySeasonalAdjustments(month: month)
        
        let julianDay = calculateJulianDay(year: year, month: month, day: day)
        return computePrayerTimes(julianDay: julianDay)
    }

    func getCalculationMethodName() -> String {
        return calculationParameters.method.rawValue
    }
    
    /// Apply adjustments based on latitude ranges
    private func applyLatitudeBasedAdjustments() {
        let absoluteLatitude = abs(latitude)
        
        if absoluteLatitude >= 60.0 {
            // Very high latitudes (Northern Scandinavia, Alaska, etc.)
            setTimeAdjustments([
                .fajr: 0,
                .sunrise: 0,
                .dhuhr: 3,
                .asr: 2,
                .maghrib: 2,
                .isha: 0
            ])
            highLatMethod = .enhancedDiyanetMethod
        } else if absoluteLatitude >= 50.0 {
            // High latitudes (Northern Europe, Canada, etc.)
            setTimeAdjustments([
                .fajr: 0,
                .sunrise: 0,
                .dhuhr: 3,
                .asr: 0,
                .maghrib: 2,
                .isha: 0
            ])
            highLatMethod = .enhancedDiyanetMethod
        } else if absoluteLatitude >= 40.0 {
            // Mid-high latitudes (Central Europe, Northern US, etc.)
            setTimeAdjustments([
                .fajr: 0,
                .sunrise: 0,
                .dhuhr: 3,
                .asr: 0,
                .maghrib: 2,
                .isha: 0
            ])
        } else if absoluteLatitude >= 30.0 {
            // Mid latitudes (Southern Europe, Central US, Middle East, etc.)
            setTimeAdjustments([
                .fajr: 0,
                .sunrise: 0,
                .dhuhr: 2,
                .asr: 0,
                .maghrib: 0,
                .isha: 0
            ])
        } else {
            // Lower latitudes (Africa, Southern Asia, etc.)
            setTimeAdjustments([
                .fajr: 0,
                .sunrise: 0,
                .dhuhr: 2,
                .asr: 0,
                .maghrib: 0,
                .isha: 0
            ])
        }
    }
    
    /// Check if current location is near the given coordinates
    private func isNear(latitude: Double, longitude: Double, maxDistance: Double) -> Bool {
        let latDiff = abs(self.latitude - latitude)
        let lonDiff = abs(self.longitude - longitude)
        return latDiff <= maxDistance && lonDiff <= maxDistance
    }
    
    /// Apply Berlin-specific adjustments based on Diyanet 2025 tables
    private func applyBerlinAdjustments() {
        var customParams = calculationParameters
        
        // Fine-tuned adjustments from Diyanet 2025 Berlin tables
        customParams.fajrAngle = 16.0
        customParams.ishaAngle = 15.0
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 0,
            .maghrib: 2,
            .isha: 0
        ])
        
        // Apply summer adjustments (March to October)
        let currentMonth = Calendar.current.component(.month, from: Date())
        if currentMonth >= 3 && currentMonth <= 10 {
            setTimeAdjustments([
                .fajr: 0,
                .sunrise: 0,
                .dhuhr: 3,
                .asr: 0,
                .maghrib: 3,  // Slightly increased for summer
                .isha: 0
            ])
        }
        
        // Set enhanced high latitude method for Berlin
        highLatMethod = .enhancedDiyanetMethod
        
        calculationParameters = customParams
    }
    
    /// Apply Athens-specific adjustments based on Diyanet 2025 tables
    private func applyAthensAdjustments() {
        var customParams = calculationParameters
        
        // Athens is at a moderate latitude
        customParams.fajrAngle = 18.0
        customParams.ishaAngle = 17.0
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Apply Hong Kong-specific adjustments based on Diyanet 2025 tables
    private func applyHongKongAdjustments() {
        var customParams = calculationParameters
        
        // Hong Kong is at lower latitude
        customParams.fajrAngle = 19.0
        customParams.ishaAngle = 18.0
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 2,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Apply Bala-specific adjustments based on Diyanet 2025 tables
    private func applyBalaAdjustments() {
        var customParams = calculationParameters
        
        // Bala (Turkey) adjustments
        customParams.fajrAngle = 18.0
        customParams.ishaAngle = 17.0
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Apply Madrid-specific adjustments based on Diyanet 2025 tables
    private func applyMadridAdjustments() {
        var customParams = calculationParameters
        
        // Fine-tuned adjustments from Diyanet 2025 Madrid tables
        customParams.fajrAngle = 18.0
        customParams.ishaAngle = 17.0
        
        setTimeAdjustments([
            .fajr: 1,     // Slight adjustment for Fajr
            .sunrise: 0,
            .dhuhr: 4,     // Madrid has a notable Dhuhr adjustment
            .asr: 0,
            .maghrib: 2,   // Slight adjustment for Maghrib
            .isha: 0
        ])
        
        // Apply summer adjustments (March to October)
        let currentMonth = Calendar.current.component(.month, from: Date())
        if currentMonth >= 3 && currentMonth <= 10 {
            setTimeAdjustments([
                .fajr: 1,
                .sunrise: 0,
                .dhuhr: 4,
                .asr: 0,
                .maghrib: 3,  // Slightly increased for summer
                .isha: 0
            ])
        }
        
        calculationParameters = customParams
    }
    
    /// Apply London-specific adjustments based on Diyanet 2025 tables
    private func applyLondonAdjustments() {
        var customParams = calculationParameters
        
        // London is high latitude, adjust method
        highLatMethod = .enhancedDiyanetMethod
        
        // Fine-tuned adjustments from Diyanet 2025 London tables
        customParams.fajrAngle = 15.0  // Lower Fajr angle for London
        customParams.ishaAngle = 14.0  // Lower Isha angle for London
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,     // London Dhuhr adjustment
            .asr: 0,
            .maghrib: 2,
            .isha: 0
        ])
        
        // Summer adjustments (April to September)
        let currentMonth = Calendar.current.component(.month, from: Date())
        if currentMonth >= 4 && currentMonth <= 9 {
            // In extreme summer months, further adjust Fajr and Isha
            if currentMonth >= 6 && currentMonth <= 7 {
                setTimeAdjustments([
                    .fajr: 0,
                    .sunrise: 0,
                    .dhuhr: 3,
                    .asr: 0,
                    .maghrib: 3,
                    .isha: 0
                ])
            }
        }
        
        calculationParameters = customParams
    }
    
    /// Apply Bucharest-specific adjustments based on Diyanet 2025 tables
    private func applyBucharestAdjustments() {
        var customParams = calculationParameters
        
        // Fine-tuned adjustments from Diyanet 2025 Bucharest tables
        customParams.fajrAngle = 17.5
        customParams.ishaAngle = 16.5
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 4,     // Bucharest Dhuhr adjustment
            .asr: 0,
            .maghrib: 2,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Apply Bern-specific adjustments based on Diyanet 2025 tables
    private func applyBernAdjustments() {
        var customParams = calculationParameters
        
        // Bern is at high latitude too
        highLatMethod = .enhancedDiyanetMethod
        
        // Fine-tuned adjustments from Diyanet 2025 Bern tables
        customParams.fajrAngle = 16.0
        customParams.ishaAngle = 15.0
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,     // Bern Dhuhr adjustment
            .asr: 0,
            .maghrib: 3,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Apply Tokyo-specific adjustments
    private func applyTokyoAdjustments() {
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 2,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
    }
    
    /// Apply Tehran-specific adjustments
    private func applyTehranAdjustments() {
        // Tehran uses different calculation parameters
        let iranParameters = CalculationMethod.tehran.parameters
        calculationParameters = CalculationParameters(
            fajrAngle: iranParameters.fajrAngle,
            ishaAngle: iranParameters.ishaAngle,
            ishaInterval: iranParameters.ishaInterval,
            maghribAngle: iranParameters.maghribAngle,
            maghribInterval: iranParameters.maghribInterval,
            method: .diyanet
        )
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 5,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
    }
    
    /// Apply Rome-specific adjustments
    private func applyRomeAdjustments() {
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 4,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
    }
    
    /// Apply Istanbul-specific adjustments
    private func applyIstanbulAdjustments() {
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
    }
    
    /// Apply Ankara-specific adjustments
    private func applyAnkaraAdjustments() {
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
    }
    
    /// Apply Dubai-specific adjustments
    private func applyDubaiAdjustments() {
        var customParams = calculationParameters
        
        // Dubai is at lower latitude
        customParams.fajrAngle = 19.0
        customParams.ishaAngle = 18.0
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Apply Riyadh-specific adjustments
    private func applyRiyadhAdjustments() {
        var customParams = calculationParameters
        
        // Use Umm Al-Qura parameters for Riyadh
        let ummAlQuraParams = CalculationMethod.ummAlQura.parameters
        customParams.fajrAngle = ummAlQuraParams.fajrAngle
        customParams.ishaAngle = ummAlQuraParams.ishaAngle
        customParams.ishaInterval = ummAlQuraParams.ishaInterval
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Apply Cairo-specific adjustments
    private func applyCairoAdjustments() {
        var customParams = calculationParameters
        
        // Use Egyptian parameters for Cairo
        let egyptianParams = CalculationMethod.egyptian.parameters
        customParams.fajrAngle = egyptianParams.fajrAngle
        customParams.ishaAngle = egyptianParams.ishaAngle
        
        setTimeAdjustments([
            .fajr: 0,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 0,
            .maghrib: 0,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Apply Moscow-specific adjustments
    private func applyMoscowAdjustments() {
        var customParams = calculationParameters
        
        // Moscow is high latitude
        highLatMethod = .enhancedDiyanetMethod
        
        // Use Russian parameters for Moscow
        let russianParams = CalculationMethod.russia.parameters
        customParams.fajrAngle = russianParams.fajrAngle
        customParams.ishaAngle = russianParams.ishaAngle
        
        setTimeAdjustments([
            .fajr: -5,
            .sunrise: 0,
            .dhuhr: 3,
            .asr: 3,
            .maghrib: 3,
            .isha: 0
        ])
        
        calculationParameters = customParams
    }
    
    /// Adjust Fajr angle based on latitude
    private func adjustFajrAngleForLocation(_ absoluteLatitude: Double) {
        var customParams = calculationParameters
        
        // Apply latitude-dependent adjustments for Fajr angles
        if absoluteLatitude >= 45.0 && absoluteLatitude < 50.0 {
            customParams.fajrAngle = 16.0
        } else if absoluteLatitude >= 50.0 && absoluteLatitude < 55.0 {
            customParams.fajrAngle = 15.0
        } else if absoluteLatitude >= 55.0 && absoluteLatitude < 60.0 {
            customParams.fajrAngle = 14.0
        } else if absoluteLatitude >= 60.0 {
            customParams.fajrAngle = 13.0
        }
        
        calculationParameters = customParams
    }
    
    /// Normalize angle to 0-360 range
    private func fixAngle(_ angle: Double) -> Double {
        var normalizedAngle = angle
        while normalizedAngle >= 360.0 { normalizedAngle -= 360.0 }
        while normalizedAngle < 0.0 { normalizedAngle += 360.0 }
        return normalizedAngle
    }
    
    /// Convert degrees to radians
    private func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }
    
    /// Convert radians to degrees
    private func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }
    
    // MARK: - Debug and Validation Methods
    
    /// Print debug information for calculated times
    func debugCalculation(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let times = calculatePrayerTimes(for: date)
        
        print("Debug calculation for \(formattedDate(date)):")
        print("Location: Lat \(latitude), Lon \(longitude)")
        print("Method: \(calculationParameters.method.rawValue)")
        print("Fajr Angle: \(calculationParameters.fajrAngle)°")
        print("Isha Angle: \(calculationParameters.ishaAngle)°")
        print("High Latitude Method: \(highLatMethod.name)")
        
        print("Prayer Times:")
        for prayer in PrayerTime.allCases {
            if let time = times[prayer] {
                print("  \(prayer.name): \(formatter.string(from: time))")
            } else {
                print("  \(prayer.name): --:--")
            }
        }
        
        print("Adjustments (minutes):")
        for prayer in PrayerTime.allCases {
            print("  \(prayer.name): \(calculationParameters.adjustments[prayer] ?? 0)")
        }
        
        print("DST Active: \(isDSTActive(for: date))")
    }
    
    /// Format date for debug output
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let monthIndex = max(0, min((components.month ?? 1) - 1, monthNames.count - 1))
        return "\(components.day ?? 1) \(monthNames[monthIndex]) \(components.year ?? 2025)"
    }
    
    /// Validate calculations against known prayer times from Diyanet tables
    func validateAgainstDiyanetTable(city: String, date: Date, referenceTimes: [PrayerTime: String]) -> [PrayerTime: (calculated: String, reference: String, difference: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let times = calculatePrayerTimes(for: date)
        
        var result: [PrayerTime: (calculated: String, reference: String, difference: Int)] = [:]
        
        for prayer in PrayerTime.allCases {
            let calculatedTimeStr = times[prayer].map { formatter.string(from: $0) } ?? "--:--"
            let referenceTimeStr = referenceTimes[prayer] ?? "--:--"
            
            // Calculate difference in minutes if both times are valid
            var diffMinutes = 0
            if calculatedTimeStr != "--:--" && referenceTimeStr != "--:--" {
                let calculatedComponents = calculatedTimeStr.split(separator: ":").map { Int($0) ?? 0 }
                let referenceComponents = referenceTimeStr.split(separator: ":").map { Int($0) ?? 0 }
                
                if calculatedComponents.count >= 2 && referenceComponents.count >= 2 {
                    let calcMinutes = calculatedComponents[0] * 60 + calculatedComponents[1]
                    let refMinutes = referenceComponents[0] * 60 + referenceComponents[1]
                    diffMinutes = calcMinutes - refMinutes
                }
            }
            
            result[prayer] = (calculated: calculatedTimeStr, reference: referenceTimeStr, difference: diffMinutes)
        }
        
        return result
    }
    
    /// Print validation results
    func printValidationResults(city: String, date: Date, results: [PrayerTime: (calculated: String, reference: String, difference: Int)]) {
        print("Validation for \(city) on \(formattedDate(date)):")
        print(String(repeating: "-", count: 60))
        print(String(format: "%-10s %-10s %-10s %-10s", "Prayer", "Calculated", "Reference", "Diff (min)"))
        print(String(repeating: "-", count: 60))
        
        for prayer in PrayerTime.allCases {
            if let result = results[prayer] {
                let diffStr = result.reference != "--:--" ? "\(result.difference)" : "N/A"
                print(String(format: "%-10s %-10s %-10s %-10s", 
                             prayer.name, 
                             result.calculated,
                             result.reference,
                             diffStr))
            }
        }
        print(String(repeating: "-", count: 60))
    }
    
    /// Comprehensive validation against multiple cities and dates
    func validateMultipleCities() {
        // Test dates throughout the year
        let testDateComponents: [(year: Int, month: Int, day: Int)] = [
            (2025, 1, 15),   // Winter
            (2025, 3, 15),   // Spring
            (2025, 6, 15),   // Summer
            (2025, 9, 15),   // Fall
            (2025, 12, 15)   // Winter
        ]
        
        // Test cities
        let testCities = ["berlin", "athens", "hongkong", "bala", "london", "madrid"]
        
        for city in testCities {
            print("\nValidating \(city.capitalized):")
            
            // Get coordinates for city
            guard let cityCoords = cityCoordinates[city] else {
                print("  Error: Coordinates not found for \(city)")
                continue
            }
            
            // Create prayer times manager for this city
            let coords = CLLocationCoordinate2D(latitude: cityCoords.latitude, longitude: cityCoords.longitude)
            let manager = PrayerTimesManager(
                coordinates: coords,
                calculationMethod: .diyanet,
                asrMethod: .standard,
                highLatitudeMethod: .enhancedDiyanetMethod,
                locationName: city
            )
            
            // Test for each date
            for dateComp in testDateComponents {
                let calendar = Calendar.current
                var components = DateComponents()
                components.year = dateComp.year
                components.month = dateComp.month
                components.day = dateComp.day
                
                guard let testDate = calendar.date(from: components) else {
                    continue
                }
                
                manager.debugCalculation(for: testDate)
                print("")
            }
        }
    }
}

// MARK: - Convenience Extensions

extension PrayerTimesManager {
    /// Get all prayer times as an array in order
    /// - Parameter date: The date to calculate prayer times for
    /// - Returns: Array of prayer times in chronological order
    func getPrayerTimesArray(for date: Date = Date()) -> [Date?] {
        let times = calculatePrayerTimes(for: date)
        return PrayerTime.allCases.map { times[$0] }
    }
    
    /// Get the next prayer time
    /// - Parameter currentTime: The reference time (default: current time)
    /// - Returns: The next prayer time, or the first prayer time of the next day if all prayers for today have passed
    func getNextPrayer(after currentTime: Date = Date()) -> (prayer: PrayerTime, time: Date, remainingMinutes: Int)? {
        let calendar = Calendar.current
        let todayTimes = calculatePrayerTimes(for: currentTime)
        
        // Find the next prayer time after the current time
        let nextPrayer = todayTimes.filter { $0.value > currentTime }
            .sorted { $0.value < $1.value }
            .first
        
        if let next = nextPrayer {
            let remainingMinutes = Int(next.value.timeIntervalSince(currentTime) / 60.0)
            return (next.key, next.value, remainingMinutes)
        } else {
            // If no more prayers today, get the first prayer of tomorrow
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentTime) {
                let tomorrowTimes = calculatePrayerTimes(for: tomorrow)
                if let firstPrayer = tomorrowTimes.sorted(by: { $0.value < $1.value }).first {
                    let remainingMinutes = Int(firstPrayer.value.timeIntervalSince(currentTime) / 60.0)
                    return (firstPrayer.key, firstPrayer.value, remainingMinutes)
                }
            }
        }
        
        return nil
    }
    
    /// Get the current prayer time (if within a prayer time window)
    /// - Parameter currentTime: The reference time (default: current time)
    /// - Returns: The current prayer time, or nil if not within any prayer time window
    func getCurrentPrayer(at currentTime: Date = Date()) -> PrayerTime? {
        let calendar = Calendar.current
        let today = calculatePrayerTimes(for: currentTime)
        let tomorrow = calculatePrayerTimes(for: calendar.date(byAdding: .day, value: 1, to: currentTime)!)
        
        // Check if between Isha and next day's Fajr
        if let isha = today[.isha], let fajr = tomorrow[.fajr],
           currentTime >= isha && currentTime < fajr {
            return .isha
        }
        
        // Check other prayer times
        let prayerWindows: [(PrayerTime, PrayerTime)] = [
            (.fajr, .sunrise),
            (.sunrise, .dhuhr),
            (.dhuhr, .asr),
            (.asr, .maghrib),
            (.maghrib, .isha)
        ]
        
        for (current, next) in prayerWindows {
            if let currentTime = today[current], let nextTime = today[next],
               currentTime <= currentTime && currentTime < nextTime {
                return current
            }
        }
        
        return nil
    }
    
    /// Format a Date as a time string
    /// - Parameters:
    ///   - date: The date to format
    ///   - format: The time format (default: "HH:mm")
    /// - Returns: The formatted time string
    static func formatTime(_ date: Date?, format: String = "HH:mm") -> String {
        guard let date = date else { return "--:--" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
