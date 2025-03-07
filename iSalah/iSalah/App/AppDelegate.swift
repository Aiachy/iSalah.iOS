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
}

extension AppDelegate {
    // Setup notification services when app launches
    func setupNotificationServices() {
        // Initialize notification manager (this will trigger singleton creation)
        
        // Request notification permissions
        NotificationManager.shared.requestAuthorization()
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


