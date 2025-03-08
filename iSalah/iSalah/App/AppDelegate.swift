//
//  AppDelegate.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//


import SwiftUI
import FirebaseCore
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        requestTrackingPermission()

        setupNotificationServices()
        setupAdMob()
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Handle discarded scenes if needed
    }
    
    // MARK: - Background Processing
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App entered background, refreshing prayer time notifications")
        
        // PrayerTimeService üzerinden güncel namaz vakitlerini almanız gerekecek
        if let salah = getAppState(),
           let location = salah.user.location {
            Task {
                let prayerTimes = await PrayerTimeService.shared.getPrayerTimes(for: location)
                await NotificationManager.shared.schedulePrayerNotifications(for: prayerTimes, days: 14)
            }
        } else {
            print("⚠️ Cannot schedule background notifications - no location or prayer times available")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("App will terminate, ensuring notifications are scheduled")
        
        // PrayerTimeService üzerinden güncel namaz vakitlerini almanız gerekecek
        if let salah = getAppState(),
           let location = salah.user.location {
            Task {
                let prayerTimes = await PrayerTimeService.shared.getPrayerTimes(for: location)
                await NotificationManager.shared.schedulePrayerNotifications(for: prayerTimes, days: 14)
            }
        }
    }

    // AppState'e erişim için yardımcı metot
    func getAppState() -> iSalahState? {
        // SceneDelegate veya diğer uygun yer üzerinden AppState'e erişim
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        // EnvironmentObject olarak erişim deneyebiliriz
        // Not: Bu direkt çalışmayabilir - uygulamanızın mimarisine göre ayarlanması gerekebilir
        let mirror = Mirror(reflecting: rootViewController)
        for child in mirror.children {
            if let state = child.value as? iSalahState {
                return state
            }
        }
        
        return nil
    }
}

extension AppDelegate {
    // Setup notification services when app launches
    func setupNotificationServices() {
        // Initialize notification manager (this will trigger singleton creation)
        let notificationManager = NotificationManager.shared
        
        // Configure notification categories and actions
        let prayerAction = UNNotificationAction(
            identifier: "MARK_AS_PRAYED",
            title: "Mark as Prayed",
            options: .foreground
        )
        
        let reminderCategory = UNNotificationCategory(
            identifier: "PRAYER_REMINDER",
            actions: [prayerAction],
            intentIdentifiers: [],
            options: []
        )
        
        let timeCategory = UNNotificationCategory(
            identifier: "PRAYER_TIME",
            actions: [prayerAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory, timeCategory])
        
        // Request notification permissions
        notificationManager.requestAuthorization()
        
        // İlk başlatma sırasında bildirimleri planlama işlemi otomatik olarak MosqueCallTimerView
        // tarafından yapılacak - buraya ek kod yazmanıza gerek yok
    }
    
    func requestTrackingPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print(
                        "İzin verildi: \(ASIdentifierManager.shared().advertisingIdentifier)"
                    )
                case .denied, .restricted, .notDetermined:
                    print("İzin reddedildi veya belirlenmedi.")
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func setupAdMob() {
        // Initialize the Google Mobile Ads SDK with app ID
        MobileAds.shared.start { status in
            print(
                "Google Mobile Ads initialization completed with status: \(status)"
            )
        }
         
#if DEBUG
        // Use test device ID for development to avoid policy violations
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = []
#endif
    }
}
