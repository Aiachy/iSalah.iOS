//
//  iSalahApp.swift
//  iSalah
//
//  Created by Mert Türedü on 16.02.2025.
//

import SwiftUI

@main
struct iSalahApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
