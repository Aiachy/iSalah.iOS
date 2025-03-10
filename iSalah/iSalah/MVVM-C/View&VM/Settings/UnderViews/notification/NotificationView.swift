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
                    VStack(spacing: 20) {
                        prayerTimersView
                    }
                    .padding(.bottom, 20)
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
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
                
                VStack(spacing: 10) {
                    /// SubTitle
                    SettingsSubTittleView("Prayer Notifications")

                    SettingsToggleRowView(.init(isOn: $vm.allNotifications, title: "All Notifications"))
                        .padding(.vertical, 5)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                        .frame(height: 1)
                    
                    SettingsToggleRowView(.init(isOn: Binding(
                        get: { vm.fajr && vm.allNotifications },
                        set: { vm.fajr = $0 }
                    ), title: "Fajr"))
                    
                    SettingsToggleRowView(.init(isOn: Binding(
                        get: { vm.sunrise && vm.allNotifications },
                        set: { vm.sunrise = $0 }
                    ), title: "Sunrise"))
                    
                    SettingsToggleRowView(.init(isOn: Binding(
                        get: { vm.dhuhr && vm.allNotifications },
                        set: { vm.dhuhr = $0 }
                    ), title: "Dhuhr"))
                    

                    SettingsToggleRowView(.init(isOn: Binding(
                        get: { vm.asr && vm.allNotifications },
                        set: { vm.asr = $0 }
                    ), title: "Asr"))

                    SettingsToggleRowView(.init(isOn: Binding(
                        get: { vm.maghrib && vm.allNotifications },
                        set: { vm.maghrib = $0 }
                    ), title: "Maghrib"))
                    
                    SettingsToggleRowView(.init(isOn: Binding(
                        get: { vm.isha && vm.allNotifications },
                        set: { vm.isha = $0 }
                    ), title: "Isha"))


                }
                .frame(width: dw(0.8))
                .padding()
        }
        .frame(width: size9)
        
    }
}
