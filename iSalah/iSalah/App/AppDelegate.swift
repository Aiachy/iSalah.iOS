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

    }
   
}

extension AppDelegate {
    
    
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
    }
}
