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
//                        testNotificationSection
                        prayerTimersView
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            // Check notification status when view appears
            vm.checkNotificationPermissionStatus()
        }
    }
}

#Preview {
    NotificationView(.init())
        .environmentObject(mockSalah)
}

extension NotificationView {
    
    // Test notification section
    private var testNotificationSection: some View {
        VStack(spacing: 10) {
            SettingsSubTittleView("Test Notifications")
            
            Button(action: {
                vm.sendTestNotification()
            }) {
                Text("Send Test Notification")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if !vm.isNotificationsAuthorized {
                Text("⚠️ Notification permissions not granted")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                    .padding(.top, 5)
                
                Button(action: {
                    vm.requestNotificationPermission()
                }) {
                    Text("Request Permission")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var prayerTimersView: some View {
        VStack {
            /// SubTitle
            SettingsSubTittleView("Prayer Notifications")
            
            VStack(spacing: 15) {
                // Master toggle for all notifications
                SettingsToggleRowView($vm.allNotifications, title: "All Notifications")
                    .padding(.bottom, 5)
                
                Divider()
                    .padding(.horizontal)
                
                // Her toggle için bireysel opacity değeri, ancak AllNotifications kapalıyken hepsi kapalı olacak
                SettingsToggleRowView(Binding(
                    get: { vm.fajr && vm.allNotifications },
                    set: { vm.fajr = $0 }
                ), title: "Fajr")
                .opacity(vm.fajr ? 1.0 : 0.6)
                
                SettingsToggleRowView(Binding(
                    get: { vm.sunrise && vm.allNotifications },
                    set: { vm.sunrise = $0 }
                ), title: "Sunrise")
                .opacity(vm.sunrise ? 1.0 : 0.6)
                
                SettingsToggleRowView(Binding(
                    get: { vm.dhuhr && vm.allNotifications },
                    set: { vm.dhuhr = $0 }
                ), title: "Dhuhr")
                .opacity(vm.dhuhr ? 1.0 : 0.6)
                
                SettingsToggleRowView(Binding(
                    get: { vm.asr && vm.allNotifications },
                    set: { vm.asr = $0 }
                ), title: "Asr")
                .opacity(vm.asr ? 1.0 : 0.6)
                
                SettingsToggleRowView(Binding(
                    get: { vm.maghrib && vm.allNotifications },
                    set: { vm.maghrib = $0 }
                ), title: "Maghrib")
                .opacity(vm.maghrib ? 1.0 : 0.6)
                
                SettingsToggleRowView(Binding(
                    get: { vm.isha && vm.allNotifications },
                    set: { vm.isha = $0 }
                ), title: "Isha")
                .opacity(vm.isha ? 1.0 : 0.6)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
