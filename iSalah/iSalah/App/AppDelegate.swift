//
//  AppDelegate.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//


import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

extension AppDelegate {
    // Setup notification services when app launches
    func setupNotificationServices() {
        // Initialize notification manager (this will trigger singleton creation)
        _ = NotificationManager.shared
        
        // Request notification permissions
        NotificationManager.shared.requestAuthorization()
    }
}
