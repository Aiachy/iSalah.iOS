import Foundation
import UIKit
import SystemConfiguration
import CoreTelephony
import AVFoundation
import Photos
import Contacts
import StoreKit

struct HarvestModel {
    // Temel bilgiler
    var deviceId: String
    var createdAt: String
    var lastLogin: String
    
    // Cihaz bilgileri
    var deviceModel: String
    var deviceName: String
    var systemName: String
    var systemVersion: String
    var deviceType: String
    
    // Ekran bilgileri
    var screenWidth: CGFloat
    var screenHeight: CGFloat
    var screenScale: CGFloat
    var isZoomed: Bool
    var screenBrightness: CGFloat
    
    // Depolama bilgileri
    var totalDiskSpace: Int64
    var freeDiskSpace: Int64
    var documentsSize: Int64
    
    // Donanım bilgileri
    var batteryLevel: Float
    var isCharging: Bool
    var processorCount: Int
    var isJailbroken: Bool
    var totalMemory: UInt64
    var availableMemory: UInt64
    
    // Ağ bilgileri
    var carrierName: String?
    var networkType: String
    var ipAddress: String?
    var isVPNActive: Bool
    
    // Bölge ve zaman bilgileri
    var languageCode: String
    var regionCode: String
    var timezoneOffset: Int
    var currency: String
    
    // Uygulama bilgileri
    var appVersion: String
    var buildNumber: String
    var firstInstallTime: String?
    var lastUpdateTime: String?
    var launchCount: Int
    var totalSessionTime: TimeInterval
    var lastSessionDuration: TimeInterval
    
    // Kullanım bilgileri
    var notificationEnabled: Bool
    var locationServicesEnabled: Bool
    var cameraPermissionStatus: String
    var microphonePermissionStatus: String
    var photoLibraryPermissionStatus: String
    var contactsPermissionStatus: String
    
    // Kullanıcı etkinliği
    var lastActiveTime: String
    var daysSinceFirstLaunch: Int
    var averageSessionLength: TimeInterval
    var appOpenCount: [String: Int] // Günlere göre app açılma sayısı
    var usageByHour: [Int: TimeInterval] // Saate göre kullanım süresi
    
    // Kullanıcı davranışı
    var screenViewCounts: [String: Int] // Ekran görüntülenme sayıları
    var buttonClickCounts: [String: Int] // Buton tıklama sayıları
    var featureUsageCounts: [String: Int] // Özellik kullanım sayıları
    var errorCounts: [String: Int] // Hata sayıları
    
    private static let userDefaultsPrefix = "com.harvest.data."
    private static let sessionStartKey = userDefaultsPrefix + "sessionStart"
    private static let launchCountKey = userDefaultsPrefix + "launchCount"
    private static let totalSessionTimeKey = userDefaultsPrefix + "totalSessionTime"
    private static let lastSessionDurationKey = userDefaultsPrefix + "lastSessionDuration"
    private static let appOpenCountKey = userDefaultsPrefix + "appOpenCount"
    private static let screenViewCountsKey = userDefaultsPrefix + "screenViewCounts"
    private static let buttonClickCountsKey = userDefaultsPrefix + "buttonClickCounts"
    private static let featureUsageCountsKey = userDefaultsPrefix + "featureUsageCounts"
    private static let errorCountsKey = userDefaultsPrefix + "errorCounts"
    private static let usageByHourKey = userDefaultsPrefix + "usageByHour"
    private static let lastActiveTimeKey = userDefaultsPrefix + "lastActiveTime"
    
    init() {
        let device = UIDevice.current
        let screen = UIScreen.main
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = Date()
        
        // Session başlatma
        UserDefaults.standard.set(currentDate.timeIntervalSince1970, forKey: HarvestModel.sessionStartKey)
        
        // Temel bilgiler
        self.deviceId = device.identifierForVendor?.uuidString ?? "unknown"
        self.createdAt = dateFormatter.string(from: currentDate)
        self.lastLogin = self.createdAt
        
        // Cihaz bilgileri
        self.deviceModel = HarvestModel.getDeviceModel()
        self.deviceName = device.name
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.deviceType = HarvestModel.getDeviceType()
        
        // Ekran bilgileri
        self.screenWidth = screen.bounds.width
        self.screenHeight = screen.bounds.height
        self.screenScale = screen.scale
        self.isZoomed = HarvestModel.isDisplayZoomed()
        self.screenBrightness = UIScreen.main.brightness
        
        // Depolama bilgileri
        self.totalDiskSpace = HarvestModel.getTotalDiskSpace()
        self.freeDiskSpace = HarvestModel.getFreeDiskSpace()
        self.documentsSize = HarvestModel.getDocumentsDirectorySize()
        
        // Donanım bilgileri
        device.isBatteryMonitoringEnabled = true
        self.batteryLevel = device.batteryLevel
        self.isCharging = device.batteryState != .unplugged
        self.processorCount = ProcessInfo.processInfo.processorCount
        self.isJailbroken = HarvestModel.isDeviceJailbroken()
        self.totalMemory = HarvestModel.getTotalMemory()
        self.availableMemory = HarvestModel.getAvailableMemory()
        
        // Ağ bilgileri
        self.carrierName = HarvestModel.getCarrierName()
        self.networkType = HarvestModel.getNetworkType()
        self.ipAddress = HarvestModel.getIPAddress()
        self.isVPNActive = HarvestModel.isVPNConnected()
        
        // Bölge ve zaman bilgileri
        self.languageCode = Locale.current.languageCode ?? "unknown"
        self.regionCode = Locale.current.regionCode ?? "unknown"
        self.timezoneOffset = TimeZone.current.secondsFromGMT() / 3600
        self.currency = Locale.current.currencyCode ?? "unknown"
        
        // Uygulama bilgileri
        let infoDictionary = Bundle.main.infoDictionary
        self.appVersion = infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        self.buildNumber = infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        self.firstInstallTime = HarvestModel.getFirstInstallTime()
        self.lastUpdateTime = HarvestModel.getLastUpdateTime()
        
        // Uygulama başlatma sayısı güncelleme
        let launchCount = UserDefaults.standard.integer(forKey: HarvestModel.launchCountKey) + 1
        UserDefaults.standard.set(launchCount, forKey: HarvestModel.launchCountKey)
        self.launchCount = launchCount
        
        // Oturum süresi bilgileri
        self.totalSessionTime = UserDefaults.standard.double(forKey: HarvestModel.totalSessionTimeKey)
        self.lastSessionDuration = UserDefaults.standard.double(forKey: HarvestModel.lastSessionDurationKey)
        
        // İzin durumları
        self.notificationEnabled = HarvestModel.isNotificationEnabled()
        self.locationServicesEnabled = HarvestModel.isLocationServicesEnabled()
        self.cameraPermissionStatus = HarvestModel.getCameraPermissionStatus()
        self.microphonePermissionStatus = HarvestModel.getMicrophonePermissionStatus()
        self.photoLibraryPermissionStatus = HarvestModel.getPhotoLibraryPermissionStatus()
        self.contactsPermissionStatus = HarvestModel.getContactsPermissionStatus()
        
        // Kullanıcı etkinliği
        self.lastActiveTime = dateFormatter.string(from: currentDate)
        UserDefaults.standard.set(self.lastActiveTime, forKey: HarvestModel.lastActiveTimeKey)
        
        if let firstInstallDate = HarvestModel.getFirstInstallDate() {
            self.daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstInstallDate, to: currentDate).day ?? 0
        } else {
            self.daysSinceFirstLaunch = 0
        }
        
        if self.launchCount > 0 && self.totalSessionTime > 0 {
            self.averageSessionLength = self.totalSessionTime / Double(self.launchCount)
        } else {
            self.averageSessionLength = 0
        }
        
        // Günlük uygulama açılış sayısı
        let dateKey = HarvestModel.getDateString(from: currentDate)
        var appOpenCount = UserDefaults.standard.dictionary(forKey: HarvestModel.appOpenCountKey) as? [String: Int] ?? [:]
        appOpenCount[dateKey] = (appOpenCount[dateKey] ?? 0) + 1
        UserDefaults.standard.set(appOpenCount, forKey: HarvestModel.appOpenCountKey)
        self.appOpenCount = appOpenCount
        
        // Saate göre kullanım süresi
        let hour = Calendar.current.component(.hour, from: currentDate)
        var usageByHour = UserDefaults.standard.dictionary(forKey: HarvestModel.usageByHourKey) as? [String: Double] ?? [:]
        self.usageByHour = [:]
        for (hourString, duration) in usageByHour {
            if let hourInt = Int(hourString) {
                self.usageByHour[hourInt] = duration
            }
        }
        
        // Kullanıcı davranışı
        self.screenViewCounts = UserDefaults.standard.dictionary(forKey: HarvestModel.screenViewCountsKey) as? [String: Int] ?? [:]
        self.buttonClickCounts = UserDefaults.standard.dictionary(forKey: HarvestModel.buttonClickCountsKey) as? [String: Int] ?? [:]
        self.featureUsageCounts = UserDefaults.standard.dictionary(forKey: HarvestModel.featureUsageCountsKey) as? [String: Int] ?? [:]
        self.errorCounts = UserDefaults.standard.dictionary(forKey: HarvestModel.errorCountsKey) as? [String: Int] ?? [:]
        
        // İnit tamamlandıktan sonra kullanım takibini başlat
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
            HarvestModel.endSession()
        }
    }
    
    // MARK: - Session Yönetimi
    
    static func endSession() {
        guard let sessionStartTime = UserDefaults.standard.object(forKey: sessionStartKey) as? TimeInterval else { return }
        
        let sessionDuration = Date().timeIntervalSince1970 - sessionStartTime
        let totalSessionTime = UserDefaults.standard.double(forKey: totalSessionTimeKey) + sessionDuration
        
        UserDefaults.standard.set(sessionDuration, forKey: lastSessionDurationKey)
        UserDefaults.standard.set(totalSessionTime, forKey: totalSessionTimeKey)
        
        // Saate göre kullanım süresi güncelleme
        let hour = Calendar.current.component(.hour, from: Date())
        var usageByHour = UserDefaults.standard.dictionary(forKey: usageByHourKey) as? [String: Double] ?? [:]
        let hourKey = String(hour)
        usageByHour[hourKey] = (usageByHour[hourKey] ?? 0) + sessionDuration
        UserDefaults.standard.set(usageByHour, forKey: usageByHourKey)
    }
    
    // MARK: - Kullanıcı Davranışı Takibi
    
    static func trackScreenView(screenName: String) {
        var screenViewCounts = UserDefaults.standard.dictionary(forKey: screenViewCountsKey) as? [String: Int] ?? [:]
        screenViewCounts[screenName] = (screenViewCounts[screenName] ?? 0) + 1
        UserDefaults.standard.set(screenViewCounts, forKey: screenViewCountsKey)
    }
    
    static func trackButtonClick(buttonId: String) {
        var buttonClickCounts = UserDefaults.standard.dictionary(forKey: buttonClickCountsKey) as? [String: Int] ?? [:]
        buttonClickCounts[buttonId] = (buttonClickCounts[buttonId] ?? 0) + 1
        UserDefaults.standard.set(buttonClickCounts, forKey: buttonClickCountsKey)
    }
    
    static func trackFeatureUsage(featureId: String) {
        var featureUsageCounts = UserDefaults.standard.dictionary(forKey: featureUsageCountsKey) as? [String: Int] ?? [:]
        featureUsageCounts[featureId] = (featureUsageCounts[featureId] ?? 0) + 1
        UserDefaults.standard.set(featureUsageCounts, forKey: featureUsageCountsKey)
    }
    
    static func trackError(errorType: String) {
        var errorCounts = UserDefaults.standard.dictionary(forKey: errorCountsKey) as? [String: Int] ?? [:]
        errorCounts[errorType] = (errorCounts[errorType] ?? 0) + 1
        UserDefaults.standard.set(errorCounts, forKey: errorCountsKey)
    }
    
    static func updateLastActiveTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        UserDefaults.standard.set(dateFormatter.string(from: Date()), forKey: lastActiveTimeKey)
    }
    
    // MARK: - Helper Methods
    
    // Model çıkarma
    private static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // Eklenebilir: İşlevsel bir model eşlemesi - örn: "iPhone12,1" -> "iPhone 11"
        return identifier
    }
    
    // Cihaz tipi
    private static func getDeviceType() -> String {
        let deviceModel = getDeviceModel()
        if deviceModel.contains("iPhone") {
            return "iPhone"
        } else if deviceModel.contains("iPad") {
            return "iPad"
        } else if deviceModel.contains("iPod") {
            return "iPod"
        } else if deviceModel.contains("Watch") {
            return "Watch"
        } else if deviceModel.contains("AppleTV") {
            return "AppleTV"
        } else {
            return "Unknown"
        }
    }
    
    // Disk alanı hesaplama
    private static func getTotalDiskSpace() -> Int64 {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let space = (systemAttributes[.systemSize] as? NSNumber)?.int64Value {
                return space
            }
        } catch {}
        return 0
    }
    
    private static func getFreeDiskSpace() -> Int64 {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let freeSpace = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            }
        } catch {}
        return 0
    }
    
    private static func getDocumentsDirectorySize() -> Int64 {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return 0
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey], options: [])
            var size: Int64 = 0
            for fileURL in contents {
                let attributes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                size += Int64(attributes.fileSize ?? 0)
            }
            return size
        } catch {
            return 0
        }
    }
    
    // Jailbreak kontrolü
    private static func isDeviceJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            fileManager.fileExists(atPath: "/bin/bash") ||
            fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
            fileManager.fileExists(atPath: "/etc/apt") ||
            fileManager.fileExists(atPath: "/usr/bin/ssh") {
            return true
        }
        
        let path = "/private/" + UUID().uuidString
        do {
            try "jailbreak test".write(toFile: path, atomically: true, encoding: .utf8)
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
        #endif
    }
    
    // Bellek bilgileri
    private static func getTotalMemory() -> UInt64 {
        return ProcessInfo.processInfo.physicalMemory
    }
    
    private static func getAvailableMemory() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return UInt64(info.resident_size)
        } else {
            return 0
        }
    }
    
    // Taşıyıcı bilgisi
    private static func getCarrierName() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            if let carriers = networkInfo.serviceSubscriberCellularProviders, let carrier = carriers.values.first {
                return carrier.carrierName
            }
        } else {
            return networkInfo.subscriberCellularProvider?.carrierName
        }
        return nil
    }
    
    // Ağ tipi
    private static func getNetworkType() -> String {
        let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com")
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if isReachable {
            if isWWAN {
                let networkInfo = CTTelephonyNetworkInfo()
                if #available(iOS 12.0, *) {
                    if let currentRadio = networkInfo.serviceCurrentRadioAccessTechnology?.values.first {
                        switch currentRadio {
                        case CTRadioAccessTechnologyLTE: return "4G"
                        case CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyGPRS: return "2G"
                        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA: return "3G"
                        default:
                            if #available(iOS 14.1, *) {
                                if currentRadio == CTRadioAccessTechnologyNRNSA || currentRadio == CTRadioAccessTechnologyNR {
                                    return "5G"
                                }
                            }
                            return "Cellular"
                        }
                    }
                }
                return "Cellular"
            } else {
                return "WiFi"
            }
        }
        return "No Connection"
    }
    
    // IP adresi
    private static func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee,
                      interface.ifa_addr.pointee.sa_family == UInt8(AF_INET) || interface.ifa_addr.pointee.sa_family == UInt8(AF_INET6),
                      let interfaceName = interface.ifa_name,
                      String(cString: interfaceName) == "en0"
                else { continue }
                
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                           &hostname, socklen_t(hostname.count),
                           nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }

    
    // VPN bağlantısı
    private static func isVPNConnected() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary else { return false }
        
        for key in keys.allKeys {
            if let interface = key as? String,
               interface.contains("tap") || interface.contains("tun") || interface.contains("ppp") || interface.contains("ipsec") {
                return true
            }
        }
        return false
    }
    
    // Ekran yakınlaştırma
    private static func isDisplayZoomed() -> Bool {
        if UIScreen.main.scale > UIScreen.main.nativeScale {
            return true
        }
        return false
    }
    
    // Uygulama yükleme zamanı
    private static func getFirstInstallTime() -> String? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: documentsUrl.path)
            if let date = attributes[FileAttributeKey.creationDate] as? Date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return formatter.string(from: date)
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    private static func getFirstInstallDate() -> Date? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: documentsUrl.path)
            return attributes[FileAttributeKey.creationDate] as? Date
        } catch {
            return nil
        }
    }
    
    // Son güncelleme zamanı
    private static func getLastUpdateTime() -> String? {
        guard let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let attributes = try? FileManager.default.attributesOfItem(atPath: infoPath),
              let date = attributes[FileAttributeKey.modificationDate] as? Date else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // Tarih metin işlemleri
    private static func getDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    // İzin durumları
    private static func isNotificationEnabled() -> Bool {
        var isEnabled = false
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                isEnabled = settings.authorizationStatus == .authorized
                semaphore.signal()
            }
        }
        
        _ = semaphore.wait(timeout: .now() + 0.1)
        return isEnabled
    }
    
    
    private static func isLocationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    private static func getCameraPermissionStatus() -> String {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .restricted: return "restricted"
        case .notDetermined: return "notDetermined"
        @unknown default: return "unknown"
        }
    }
    
    private static func getMicrophonePermissionStatus() -> String {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .restricted: return "restricted"
        case .notDetermined: return "notDetermined"
        @unknown default: return "unknown"
        }
    }
    
    private static func getPhotoLibraryPermissionStatus() -> String {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .restricted: return "restricted"
        case .notDetermined: return "notDetermined"
        case .limited: return "limited"
        @unknown default: return "unknown"
        }
    }
    
    private static func getContactsPermissionStatus() -> String {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .restricted: return "restricted"
        case .notDetermined: return "notDetermined"
        @unknown default: return "unknown"
        }
    }
    
    // JSON dönüşümü
    func toJSON() -> [String: Any] {
        var jsonDict: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            guard let key = child.label else { continue }
            jsonDict[key] = child.value
        }
        
        return jsonDict
    }
    
    // MARK: - Veri Kaydetme ve Gönderme
    
    func saveLocally() {
        let jsonData = try? JSONSerialization.data(withJSONObject: self.toJSON(), options: [])
        if let data = jsonData {
            let fileManager = FileManager.default
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileName = "harvest_data_\(Date().timeIntervalSince1970).json"
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                do {
                    try data.write(to: fileURL)
                    print("Harvest data başarıyla kaydedildi: \(fileURL.path)")
                } catch {
                    print("Harvest data kaydedilemedi: \(error)")
                }
            }
        }
    }
    
    func sendToServer(endpoint: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(false, NSError(domain: "HarvestModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Geçersiz URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.toJSON(), options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, NSError(domain: "HarvestModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Geçersiz yanıt"]))
                    return
                }
                
                completion(200...299 ~= httpResponse.statusCode, nil)
            }
            
            task.resume()
        } catch {
            completion(false, error)
        }
    }
    
    // MARK: - Veri Silme ve Sıfırlama
    
    static func resetLocalData() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: launchCountKey)
        userDefaults.removeObject(forKey: totalSessionTimeKey)
        userDefaults.removeObject(forKey: lastSessionDurationKey)
        userDefaults.removeObject(forKey: appOpenCountKey)
        userDefaults.removeObject(forKey: screenViewCountsKey)
        userDefaults.removeObject(forKey: buttonClickCountsKey)
        userDefaults.removeObject(forKey: featureUsageCountsKey)
        userDefaults.removeObject(forKey: errorCountsKey)
        userDefaults.removeObject(forKey: usageByHourKey)
        userDefaults.removeObject(forKey: lastActiveTimeKey)
    }
    
    static func deleteLocalFiles() {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
                for fileURL in fileURLs where fileURL.lastPathComponent.starts(with: "harvest_data_") {
                    try fileManager.removeItem(at: fileURL)
                }
            } catch {
                print("Harvest dosyaları silinirken hata oluştu: \(error)")
            }
        }
    }
}
