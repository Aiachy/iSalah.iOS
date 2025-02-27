//
//  iSalahApp.swift
//  iSalah
//
//  Created by Mert Türedü on 16.02.2025.
//

import SwiftUI

@main
struct iSalahApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var salah: iSalahState = .init()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(salah)
        }
    }
}
