//
//  NotificationView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct NotificationView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: NotificationViewModel
    
    init(
        _ coordinator: SettingsCoordinatorPresenter
    ) {
        _vm = StateObject(wrappedValue: NotificationViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                /// Header
                SettingsHeaderView("Notification", back: vm.makeBackButton)
                ScrollView(.vertical) {
                    prayerTimersView
                }
            }
        }
    }
}

#Preview {
    NotificationView(.init())
        .environmentObject(mockSalah)
}

extension NotificationView {

    private var prayerTimersView: some View {
        VStack {
            /// SubTitle
            SettingsSubTittleView("Prayer Notifications")
            
            VStack(spacing: 15) {
                SettingsToggleRowView($vm.fajr, title: "Fajr")
                SettingsToggleRowView($vm.sunrise, title: "Sunrise")
                SettingsToggleRowView($vm.dhuhr, title: "Dhuhr")
                SettingsToggleRowView($vm.asr, title: "Asr")
                SettingsToggleRowView($vm.maghrib, title: "Maghrib")
                SettingsToggleRowView($vm.isha, title: "Isha")
            }
        }
    }
  
}
